; Inno Setup script for the WezTerm + Neovim dev environment.
; Build:  iscc /DAppVersion=1.2.3 installer\windows\installer.iss
; Output: dist\WezTerm-DevEnv-Setup.exe
;
; Model: terminals install on Windows (winget); Neovim + CLI + Claude config
; install inside WSL. The selected components are forwarded to bootstrap.ps1.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#define AppName "WezTerm DevEnv"
#define RepoRoot "..\.."

[Setup]
AppId={{8F3C6B2E-1D4A-4E7B-9C2F-7A6E5D4C3B21}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=SejuneOh
DefaultDirName={localappdata}\WezTermDevEnv
DisableDirPage=yes
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir={#RepoRoot}\dist
OutputBaseFilename=WezTerm-DevEnv-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Types]
Name: "full";   Description: "전체 설치 (WezTerm + Neovim/WSL + 폰트)"
Name: "custom"; Description: "사용자 지정"; Flags: iscustom

[Components]
Name: "wezterm";   Description: "WezTerm 터미널 + 설정";                 Types: full custom; Flags: checkablealone
Name: "alacritty"; Description: "Alacritty 터미널 + 설정";              Types: custom
Name: "nerdfont";  Description: "D2CodingLigature Nerd Font";          Types: full custom
Name: "wslnvim";   Description: "WSL 안에 Neovim 개발 환경 구성 (권장)"; Types: full custom
Name: "claude";    Description: "Claude Code 설정을 WSL에 설치";        Types: custom

[Files]
; Bundle the repo content so the install runs offline. {app} is the payload.
Source: "{#RepoRoot}\nvim\*";      DestDir: "{app}\nvim";      Flags: recursesubdirs createallsubdirs ignoreversion
Source: "{#RepoRoot}\wezterm\*";   DestDir: "{app}\wezterm";   Flags: recursesubdirs createallsubdirs ignoreversion
Source: "{#RepoRoot}\alacritty\*"; DestDir: "{app}\alacritty"; Flags: recursesubdirs createallsubdirs ignoreversion
Source: "{#RepoRoot}\claude\*";    DestDir: "{app}\claude";    Flags: recursesubdirs createallsubdirs ignoreversion; Components: claude
Source: "{#RepoRoot}\installer\*"; DestDir: "{app}\installer"; Flags: recursesubdirs createallsubdirs ignoreversion

[Run]
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\installer\windows\bootstrap.ps1"" -Payload ""{app}"" -Components ""{code:GetComponents}"""; \
  StatusMsg: "개발 환경을 설치하는 중입니다 (winget + WSL)..."; \
  Flags: waituntilterminated

[Code]
function GetComponents(Param: String): String;
var
  s: String;
begin
  s := '';
  if WizardIsComponentSelected('wezterm')   then s := s + 'wezterm,';
  if WizardIsComponentSelected('alacritty') then s := s + 'alacritty,';
  if WizardIsComponentSelected('nerdfont')  then s := s + 'nerd-font,';
  if WizardIsComponentSelected('wslnvim')   then s := s + 'wsl-nvim,';
  if WizardIsComponentSelected('claude')    then s := s + 'claude,';
  if Length(s) > 0 then
    s := Copy(s, 1, Length(s) - 1);
  Result := s;
end;
