# Refactoring plan: scripts and zsh functions
*2026-04-25 09:27 PDT*

## Guiding principle

A function should only be a function when it must modify the calling shell.
Otherwise, it should be a script.

Functions are required when they `cd`, `export`, modify aliases or history,
change job-control state, or otherwise mutate the parent process. Everything
else belongs as a versioned, testable, shellcheck-clean script in `~/bin`.

Putting non-shell-state logic in `.zshrc` slows shell startup, prevents
`shellcheck` from analyzing it, makes per-function review and history harder,
and bloats the file you have to scan when you actually want to find a config
setting.

The current state violates this principle in both directions. `.zshrc`
carries roughly 280 lines of pure logic that does not touch shell state
(`gz`, `_gz_secret_scan`, `gz-scan-history`, `mma`, `pp`, `rr`, `mr`, `nav`),
and `~/bin` carries a few microscripts that are aliases in disguise
(`bb`, `gg`, `k`).

## Categorization

### Keep as zsh functions (must mutate parent shell)

| Function                                     | Why it must stay a function    |
| -------------------------------------------- | ------------------------------ |
| `d`                                          | Reads parent dir-stack         |
| `ff`                                         | `cd "$(dirname "$file")"`      |
| `_zzcollab_root`                             | Helper used by `z*` and `mr`   |
| `za zw zy zf zt zs zp zr z0 zm ze zo zc zg`  | All `cd` to a project subdir   |

### Move out of `.zshrc` into `~/bin` (no shell state)

| Currently           | New location                            | Notes                            |
| ------------------- | --------------------------------------- | -------------------------------- |
| `gz` (~200 lines)   | `~/bin/gz`                              | Marquee win; pure git/io         |
| `_gz_secret_scan`   | `~/bin/lib/gz-secret-scan.sh` (sourced) | Or fold into `gz`                |
| `gz-scan-history`   | `~/bin/gz-scan-history`                 |                                  |
| `mma`               | `~/bin/mma`                             | macOS guard inside script        |
| `pp`                | `~/bin/pp`                              | Forks `zathura &`                |
| `rr`                | `~/bin/rr`                              | Forks `vim`                      |
| `mr`                | `~/bin/mr`                              | Inline `_zzcollab_root` at top   |
| `nav`               | `~/bin/nav`                             | Pure printf; or generate         |

### Convert tiny scripts to aliases

| Script | Replacement in `.zshrc`                                              |
| ------ | -------------------------------------------------------------------- |
| `bb`   | `alias bb='vim ~/docs/personal/preludelist.tex'`                     |
| `gg`   | `alias gg='nohup /Applications/Ghostty.app/Contents/MacOS/ghostty >/dev/null 2>&1 &'` |
| `k`    | `alias k='nohup /Applications/kitty.app/Contents/MacOS/kitty >/dev/null 2>&1 &'`      |

These three are not real programs; they are one-liners that happen to live
on disk. Promoting them to aliases removes three files, makes them visible
in `alias` output, and matches `qq='qutebrowser &'` which is already an
alias. (`start` is a similar case but is a chain of independent commands;
keep it as a script.)

### Keep as scripts, but harden

These are correctly scripts; they need standardization. For each: shebang,
`set -euo pipefail`, quoted variables, `$(...)` over backticks, a clean
`shellcheck` pass, and a `-h`/`--help` flag for non-trivial ones.

| Group                | Files                                                                   |
| -------------------- | ----------------------------------------------------------------------- |
| Side-effect launchers| `qcp`, `zz`, `ss`, `vv`, `p1`, `p2`, `init`, `start`                    |
| Notes/clipboard      | `n1`, `research_update`, `claudenotes`, `tn`                            |
| Mail/HTML            | `viewhtmlmsg`, `mutt-notmuch-py`                                        |
| Git/repo ops         | `git-sync.sh`, `git-repo-push.sh`, `backup_research.sh`,                |
|                      | `check-ci-status.sh`, `archive_and_delete_repos.sh`,                    |
|                      | `delete_dockerhub_repos.sh`                                             |
| Cloud sync           | `rclone_*.sh` (x4)                                                      |
| Cloud setup          | `aws_*.sh` (x4), `setup_ucsd_mail.sh`                                   |
| Maintenance          | `cleanup_apps.sh`, `cleanup_home.sh`, `fix_symlinks.sh`,                |
|                      | `reorganize_research_project.sh`, `ls_since.sh`, `md2pdf.sh`,           |
|                      | `list-renv-packages.sh`                                                 |
| Installers           | `bootstrap.sh`, `install.sh`, `zzreset.sh`                              |
| R / research         | `rrtools_plus.sh`, `check_renv_for_commit.R`, `prj_init.sh`             |
| Opaque binary        | `wisu` (leave untouched; no source here)                                |

### Audit for redundancy and decommissioning

| Item                                                  | Concern                                                          |
| ----------------------------------------------------- | ---------------------------------------------------------------- |
| `n1` vs `tn` vs `claudenotes` vs `research_update`    | All four capture research notes from clipboard or dictation. At least two probably overlap; pick one and retire the rest. |
| `ss` vs `zz`                                          | Same script with `Skim` vs `zathura`; could be one with a `--viewer` flag or `$PDF_VIEWER` env var. |
| `vv` vs `rr`                                          | Mirror each other with different file extensions; consolidate.   |
| `bootstrap.sh` vs `install.sh`                        | Both install something; targets differ. Document or consolidate. |
| `archive/` retirees                                   | `rrtools.sh.bak2`, `rrtools_original.sh`, `pull-all.sh`, `sync-all.sh`, `chatnotes_modified.sh`, `rename_master_to_main.sh`, etc. are dead weight. Git history preserves them; remove from working tree. |

## Execution plan

Each phase is independently shippable and reversible.

### Phase 1: Extract the `gz` family (highest leverage)

1. Create `~/bin/gz` with the body of `gz()` from
   `~/Dropbox/dotfiles/zshrc` lines 267 to 459. Add `#!/usr/bin/env zsh`
   (the function uses zsh-specific globbing such as `${(f)...}` and
   `${unstaged:#}`; bash will not run it as-is). Use `set -u` but skip
   `-e`, since the function relies on continuing past failed scans.
2. Create `~/bin/gz-scan-history` similarly.
3. Decide between inlining `_gz_secret_scan` into `gz` or placing it in
   `~/bin/lib/gz-secret-scan.zsh` and sourcing via
   `source "${0:A:h}/lib/gz-secret-scan.zsh"`. Inline is simpler; the
   library path is reusable.
4. Delete `gz`, `_gz_secret_scan`, and `gz-scan-history` from `.zshrc`.
5. Verify `gz` end-to-end on a scratch repository, exercising both the
   clean path and a path with gitleaks findings, then verify
   `gz-scan-history`.

Net effect: roughly 280 lines leave `.zshrc`, shell startup is faster,
both functions become shellcheck-able.

### Phase 2: Extract the small functions

Move `pp`, `rr`, `mma`, `mr`, `nav` to `~/bin/{pp,rr,mma,mr,nav}`. Each
needs `#!/usr/bin/env zsh` (the `rg --files | fzf` pattern works in bash
too, but zsh keeps the family consistent). For `mr`, copy
`_zzcollab_root` inline.

Delete the originals from `.zshrc`. The `_zzcollab_root` function stays
in `.zshrc` because `za`, `zw`, and the rest still need it.

### Phase 3: Convert microscripts to aliases

Delete `~/Dropbox/bin/{bb,gg,k}`. Add the three aliases to `.zshrc`
section 10.

### Phase 4: Standardize the remaining `~/bin` scripts

Walk the 'Keep as scripts, but harden' list. For each script:

- Add `#!/usr/bin/env bash` (or `zsh`) if missing.
- Add `set -euo pipefail` unless the script intentionally tolerates
  failures (e.g., `backup_research.sh` chooses its own policy).
- Replace backticks with `$(...)`.
- Quote `"$1"`, `"$PWD"`, and similar.
- Resolve `shellcheck` warnings.
- Add `-h`/`--help` for any script over roughly 30 lines.
- Decide on extension policy (see below).

Extension policy: drop `.sh` on user-facing executables (`git-sync`,
`md2pdf`, `cleanup-apps`). Standard Unix style. Keep `.sh` only on
scripts that are explicitly sourced rather than executed. Caveat:
`backup_research.sh` is referenced by name in
`launchd/local.backup.research.plist`; rename together or leave as `.sh`.
Verify with `rg backup_research.sh launchd/`.

### Phase 5 (optional): Autoload kept functions

For an even leaner `.zshrc`, move `d`, `ff`, `za`/`zw`/etc., and
`_zzcollab_root` to `~/.zsh/functions/` (one file per function, no
shebang, just the body). Then in `.zshrc`:

```zsh
fpath=(~/.zsh/functions $fpath)
autoload -Uz d ff _zzcollab_root za zw zy zf zt zs zp zr \
  z0 zm ze zo zc zg
```

Functions load on first call, so this is also a small startup win. Skip
if reading function bodies in `.zshrc` is preferable.

### Phase 6: Tooling guardrails

Add a `shellcheck` pre-commit hook for `~/Dropbox/bin/*`, skipping
`archive/`, `wisu`, `*.R`, and `*.py`. This catches regressions and pays
back continuously. Optional: a `make lint` target in `~/bin` that runs
`shellcheck` over all executables.

### Phase 7: Decommission

Apply the redundancy audit:

- Pick one of `n1`, `tn`, `claudenotes`, `research_update`; retire the
  rest (move to `archive/` or `git rm`).
- Merge `ss` and `zz` into one viewer-aware script; do the same for `vv`
  and `rr`.
- Clear `archive/`'s legacy `.sh.bak2` and `_original.sh` files; git
  history preserves them.

## Non-goals

- Do not try to make `gz` portable to bash. It is deeply zsh: `${(f)...}`,
  `${array:#}`, and `setopt` semantics. Document `#!/usr/bin/env zsh` and
  move on.
- Do not convert long scripts (`tn`, `rrtools_plus.sh`, `prj_init.sh`)
  into multi-file modules. They are imperative tools, not libraries.
- Do not normalize the macOS vs. Linux split inside scripts beyond what
  already works. The `~/Dropbox/bin` tree is primarily macOS;
  cross-platform behavior is a `.zshrc` concern.

## Estimated effort

| Phase                          | Effort                       | Risk                                              |
| ------------------------------ | ---------------------------- | ------------------------------------------------- |
| 1. Extract `gz` family         | 30 to 60 minutes             | Low (well-scoped; test on a scratch repo)         |
| 2. Extract small functions     | 20 minutes                   | Low                                               |
| 3. Microscripts to aliases     | 5 minutes                    | None                                              |
| 4. Standardize ~30 scripts     | 2 to 4 hours, incrementable  | Medium (legacy quoting bugs may surface)          |
| 5. Autoload conversion         | 30 minutes                   | Low (optional)                                    |
| 6. shellcheck hook             | 15 minutes                   | None                                              |
| 7. Decommission                | 30 minutes                   | Low (verify nothing in `launchd/` references retired names) |

Phases 1 through 3 alone require roughly 90 minutes and produce most of
the visible benefit. Phase 4 is the long tail and can be done one script
at a time as the scripts are encountered.
