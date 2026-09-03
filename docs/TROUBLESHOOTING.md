# Troubleshooting

Known failure modes in this environment, with the evidence to confirm each one
and the fix.

## Table of Contents

- [C# diagnostics report missing types on code that compiles](#c-diagnostics-report-missing-types-on-code-that-compiles)

---

## C# diagnostics report missing types on code that compiles

### Symptom

You open a `.cs` file in Neovim and get diagnostics like "The type or namespace
name 'X' could not be found" even though the `using` directives are correct.
`dotnet build` on the same code reports no warnings. Roslynator (`RCS*`)
warnings may also appear twice on the same line.

Most likely on large solutions. A solution with only a few projects may never
hit the limit described below, so the same config can look fine elsewhere.

### Cause

Two Roslyn language servers run at once, and one of them exhausts the system
inotify budget so the other cannot load any project.

1. `easy-dotnet.nvim` defaults to `lsp.enabled = true`. Left at the default it
   starts its own Roslyn server (`dotnet-easydotnet roslyn start --roslynator
   --easy-dotnet-analyzer`) alongside the mason Roslyn server that
   `roslyn.nvim` manages.

2. A Roslyn server allocates a `FileSystemWatcher` per loaded project, and each
   one costs an inotify instance. WSL2 defaults to
   `fs.inotify.max_user_instances = 128`. In the observed case the easy-dotnet
   server alone held 102 instances, with the system at 120/128.

3. With the budget gone, project loading in the other server throws:

   ```
   Error while loading .../Some.Project.csproj:
   System.IO.IOException: The configured user limit (128) on the number of
   inotify instances has been reached
      at System.IO.FileSystemWatcher.StartRaisingEvents()
   ```

4. Files belonging to a project that failed to load fall back to Roslyn's
   miscellaneous-files workspace:

   ```
   roslyn-canonical-misc/<guid>/Canonical.csproj has unresolved ...
   ```

   That workspace carries no `ProjectReference` and no `PackageReference`, so
   correct `using` directives resolve to nothing and every external type looks
   undefined.

Note that `automatic_enable = false` in `nvim/lua/plugins/mason.lua` stops
mason-lspconfig from auto-starting servers such as omnisharp, but it does not
cover a plugin that spawns a server itself.

### Confirm it

Count inotify instances per process and compare against the limit:

```bash
cat /proc/sys/fs/inotify/max_user_instances

for p in $(ls /proc | grep -E '^[0-9]+$'); do
  n=$(ls -l /proc/$p/fd 2>/dev/null | grep -c inotify)
  [ "$n" -gt 0 ] && echo "$n  pid=$p  $(tr -d '\0' < /proc/$p/cmdline | cut -c1-80)"
done | sort -rn | head
```

Check whether the server actually hit the limit, and whether files landed in the
fallback workspace:

```bash
grep -c 'inotify instances has been reached' ~/.local/state/nvim/lsp.log
grep -a -o 'roslyn-canonical-misc[^"]\{0,60\}' ~/.local/state/nvim/lsp.log | tail
```

Confirm only one Roslyn server is attached:

```bash
ps -eo pid,ppid,args | grep -E 'Microsoft.CodeAnalysis.LanguageServer|easydotnet roslyn' | grep -v grep
```

### Fix

**1. Config (already applied in this repo).**
`nvim/lua/plugins/easy-dotnet.lua` disables the plugin's own language servers:

```lua
lsp = { enabled = false },
projx_lsp = { enabled = false },
```

C# LSP is owned by `roslyn.nvim`. The `Dotnet build` / `Dotnet test` /
`Dotnet run` commands and the test runner are unaffected.

**2. Raise the inotify limits (system setting, not managed by this repo).**
The default of 128 instances is low for multi-project .NET solutions:

```bash
echo -e "fs.inotify.max_user_instances = 1024\nfs.inotify.max_user_watches = 1048576" \
  | sudo tee /etc/sysctl.d/99-inotify.conf
sudo sysctl --system
```

On WSL2 this persists across restarts when `/etc/wsl.conf` has `systemd=true`.

**3. Restart Neovim completely.** Each running Neovim instance owns its own
language servers, so `:LspRestart` in one window is not enough. Quit every
Neovim process and reopen.

### Related setting

Leave `filewatching = "auto"` in `nvim/lua/plugins/roslyn.lua` as is. The log
line `We are unable to use LSP file watching; falling back to our in-process
watcher` means the server watches files itself, which is fine once the limits
are raised. Setting it to `"off"` avoids inotify entirely but drops detection of
external changes such as a `git checkout`, requiring a manual `:LspRestart`
after each one.
