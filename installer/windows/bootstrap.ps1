<#
.SYNOPSIS
  Windows installer logic for the WezTerm + Neovim dev environment.

.DESCRIPTION
  Model: the GUI terminals (WezTerm / Alacritty) install on Windows via winget;
  the shell + Neovim live inside WSL. So this script installs the selected
  terminals + their Windows-side configs + the Nerd Font, then (optionally)
  shells into WSL and runs the shared common installer to set up Neovim, the CLI
  tooling, and the Claude config inside the Linux home.

  Invoked by the Inno Setup installer (installer.iss) with the user's selected
  components, or runnable directly. Source of truth for IDs: installer/manifest.json.

.PARAMETER Payload
  Directory holding the bundled repo content (nvim/, wezterm/, alacritty/,
  claude/, installer/). Inno Setup sets this to {app}.

.PARAMETER Components
  Comma list from: wezterm, alacritty, nerd-font, wsl-nvim, claude

.PARAMETER WslDistro
  WSL distro name. Empty = the default distro.
#>
param(
    [Parameter(Mandatory = $true)][string]$Payload,
    [string]$Components = "wezterm,nerd-font,wsl-nvim",
    [string]$WslDistro = "",
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
function Info($m) { Write-Host "[info]  $m" -ForegroundColor Cyan }
function Warn($m) { Write-Host "[warn]  $m" -ForegroundColor Yellow }
function Plan($m) { Write-Host "[plan]  $m" -ForegroundColor Magenta }
function Has($c)  { return (",$Components," -like "*,$c,*") }

function Invoke-Step([string]$desc, [scriptblock]$action) {
    if ($DryRun) { Plan $desc } else { Info $desc; & $action }
}

# ---------------------------------------------------------------------------
# winget helpers
# ---------------------------------------------------------------------------
function Ensure-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) { return }
    throw "winget not found. Install 'App Installer' from the Microsoft Store, then re-run."
}

function Winget-Install([string]$id) {
    Invoke-Step "winget install $id" {
        winget install --id $id --exact --silent `
            --accept-package-agreements --accept-source-agreements `
            --disable-interactivity 2>&1 | Out-Host
        # winget returns non-zero when the package is already installed; tolerate it.
        if ($LASTEXITCODE -ne 0) { Warn "winget exit $LASTEXITCODE for $id (often 'already installed')." }
    }
}

function Backup-IfExists([string]$path) {
    if (Test-Path -LiteralPath $path) {
        $ts = Get-Date -Format "yyyyMMdd-HHmmss"
        $bak = "$path.backup-$ts"
        Invoke-Step "backup $path -> $bak" { Move-Item -LiteralPath $path -Destination $bak -Force }
    }
}

function Copy-Config([string]$src, [string]$dest) {
    Backup-IfExists $dest
    Invoke-Step "copy $src -> $dest" {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
        Copy-Item -LiteralPath $src -Destination $dest -Force -Recurse
    }
}

# ---------------------------------------------------------------------------
# components
# ---------------------------------------------------------------------------
function Install-WezTerm {
    Ensure-Winget
    Winget-Install "wez.wezterm"
    Copy-Config (Join-Path $Payload "wezterm\.wezterm.lua") (Join-Path $env:USERPROFILE ".wezterm.lua")
}

function Install-Alacritty {
    Ensure-Winget
    Winget-Install "Alacritty.Alacritty"
    Copy-Config (Join-Path $Payload "alacritty\windows\alacritty.toml") (Join-Path $env:APPDATA "alacritty\alacritty.toml")
}

function Install-NerdFont {
    Invoke-Step "install D2CodingLigature Nerd Font (per-user)" {
        $tmp = Join-Path $env:TEMP "d2coding-nerd"
        $zip = "$tmp.zip"
        Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/D2Coding.zip" -OutFile $zip
        if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
        Expand-Archive -Path $zip -DestinationPath $tmp -Force

        $fontDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
        New-Item -ItemType Directory -Force -Path $fontDir | Out-Null
        $regKey = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
        Get-ChildItem -Path $tmp -Recurse -Include *.ttf, *.otf | ForEach-Object {
            $target = Join-Path $fontDir $_.Name
            Copy-Item -LiteralPath $_.FullName -Destination $target -Force
            Set-ItemProperty -Path $regKey -Name "$($_.BaseName) (TrueType)" -Value $target
        }
    }
}

# Translate a Windows path to its /mnt/... WSL path and run the common installer.
function Setup-Wsl([string]$wslComponents) {
    if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
        Warn "WSL not found — skipping Neovim setup. Install WSL: 'wsl --install', then re-run."
        return
    }
    $distroArgs = @()
    if ($WslDistro -ne "") { $distroArgs = @("-d", $WslDistro) }

    # Resolve the payload's path as seen from inside WSL.
    $wslPayload = (& wsl @distroArgs wslpath -a "$Payload").Trim()
    $cmd = "bash '$wslPayload/installer/common/install-nvim-env.sh' --payload '$wslPayload' --components '$wslComponents'"
    if ($DryRun) { $cmd = "$cmd --dry-run" }

    Invoke-Step "WSL: $cmd" {
        & wsl @distroArgs -- bash -lc $cmd
        if ($LASTEXITCODE -ne 0) { Warn "WSL bootstrap returned $LASTEXITCODE." }
    }
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
Info "Components: $Components"
if ($DryRun) { Info "DRY-RUN: no changes will be made." }

if (Has "wezterm")   { Install-WezTerm }
if (Has "alacritty") { Install-Alacritty }
if (Has "nerd-font") { Install-NerdFont }

# Neovim + CLI (+ Claude) live in WSL; build the component list the Linux
# common installer understands and run it once.
$wslComponents = @()
if (Has "wsl-nvim") { $wslComponents += "core"; $wslComponents += "nerd-font" }
if (Has "claude")   { $wslComponents += "claude" }
if ($wslComponents.Count -gt 0) {
    Setup-Wsl ($wslComponents -join ",")
}

Info "Windows setup complete."
if (Has "wsl-nvim") { Info "Launch WezTerm/Alacritty; it drops into WSL where 'nvim' is ready." }
