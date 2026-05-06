# ==========================================================================
# ZSH CONFIGURATION - REFACTORED FOR ZZCOLLAB DOCKER FILTERING
# ==========================================================================
#
# 🍎 MACOS-SPECIFIC CONTENT GROUPED FOR EASY IDENTIFICATION:
#
# The following sections contain macOS-specific content that will be
# automatically filtered out when creating Docker-compatible .zshrc_docker:
#
# - Section 3: macOS-specific configuration (Homebrew paths, etc.)
# - Section 8: Plugin management (brew --prefix paths)
# - Section 10: macOS-specific aliases (open, Skim, etc.)
# - Section 11: macOS-specific functions (Mathematica, etc.)
# - Section 12: macOS-specific external tools (conda paths, etc.)
#
# All sections marked with 🍎 will be removed or replaced in Docker containers.
#
# ==========================================================================

# ==========================================================================
# 1. ENVIRONMENT & SECURITY
# ==========================================================================

# Security: Source sensitive environment variables from separate file
[[ -f ~/.env ]] && source ~/.env

# ==========================================================================
# 2. CORE SHELL CONFIGURATION (Cross-platform)
# ==========================================================================

# Basic exports
export EDITOR="vim"
export VIMINIT='source ~/.config/vim/vimrc'
export DOCKER_BUILDKIT=1
export GITHUB_USER="rgt47"

# TeX configuration
export TEXINPUTS=".:$HOME/shr/images:$HOME/shr:"
export BIBINPUTS=".:$HOME/shr/bibfiles:$HOME/shr"

# ==========================================================================
# 3. MACOS-SPECIFIC CONFIGURATION
# ==========================================================================
# 🍎 ALL MACOS-SPECIFIC SETTINGS GROUPED HERE FOR EASY IDENTIFICATION

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS-specific application configuration
    export HOMEBREW_AUTO_UPDATE_SECS="604800"

    # macOS PATH configuration (includes Homebrew paths)
    # SECURITY FIX: Removed leading "." from PATH
    export PATH="$HOME/bin:$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
else
    # Linux PATH configuration
    export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
fi

# ==========================================================================
# 4. CORE SHELL OPTIONS (Cross-platform)
# ==========================================================================

# Directory shortcuts
cdpath=($HOME/Dropbox $HOME/Dropbox/prj $HOME/Dropbox/sbx $HOME/Dropbox/work)

# Basic shell options
setopt auto_cd auto_pushd pushd_ignore_dups pushdminus
setopt PROMPT_SUBST

# Vi mode
bindkey -v

# Double hyphen to underscore
bindkey -s -- '--' '_'

# ==========================================================================
# 5. HISTORY MANAGEMENT (Cross-platform)
# ==========================================================================

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_DUPS INC_APPEND_HISTORY HIST_VERIFY

# ==========================================================================
# 6. COMPLETION & NAVIGATION (Cross-platform)
# ==========================================================================

# PERFORMANCE: Completion system with caching (only rebuild once per day)
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi
compdef _dirs d

# ==========================================================================
# 7. PROMPT & VCS INTEGRATION (Cross-platform)
# ==========================================================================

# Version control setup
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%b '

# Custom prompt
PROMPT='%F{cyan}%m%f %F{green}%*%f %F{yellow}${PWD/$HOME/~}%f %F{red}${vcs_info_msg_0_}%f$ %(?:☕  :☔  )'

# ==========================================================================
# 8. PLUGIN MANAGEMENT (Platform-aware)
# ==========================================================================

# Load plugins based on OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux plugin paths
    [[ -s /home/z/.autojump/etc/profile.d/autojump.sh ]] && source /home/z/.autojump/etc/profile.d/autojump.sh
    [[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
    [[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # 🍎 macOS plugin paths (uses Homebrew)
    # PERFORMANCE: Cache brew --prefix to avoid slow command on every shell startup
    if [[ -z "$BREW_PREFIX" ]]; then
        export BREW_PREFIX="/opt/homebrew"
    fi
    [[ -f "$BREW_PREFIX/etc/profile.d/autojump.sh" ]] && source "$BREW_PREFIX/etc/profile.d/autojump.sh"
    [[ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [[ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Plugin configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=red,bold,underline'

# ==========================================================================
# 9. TOOL-SPECIFIC CONFIGURATION (Cross-platform)
# ==========================================================================

# FZF configuration
if type rg &> /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden'
    export FZF_DEFAULT_OPTS='-m --height 50% --border --reverse'
fi

# ==========================================================================
# 10. ALIASES (Cross-platform)
# ==========================================================================

# Navigation aliases
alias -- -='cd -'
alias -g ...='../..'

# File listing with color support (OS-aware)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS (BSD ls) - check if GNU ls is installed via coreutils
    if command -v gls &> /dev/null; then
        alias ls='gls --color=auto'
        alias ll='gls -lh --color=auto'
    else
        alias ls='ls -G'
        alias ll='ls -lhG'
    fi
else
    # Linux (GNU ls)
    alias ls='ls --color=auto'
    alias ll='ls -lh --color=auto'
fi


# Directory stack navigation
alias lt='eza -lrha -sold'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'

# Color support for common tools
alias grep='grep --color=auto'

# diff with color (OS-aware)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS diff doesn't support --color, check for GNU diff
    if command -v gdiff &> /dev/null; then
        alias diff='gdiff --color=auto'
    fi
else
    alias diff='diff --color=auto'
fi

# Application shortcuts
alias hh='history'
alias R='R --quiet --no-save'
alias mm='mutt'
alias v='vim'
alias ZZ='exit'

# Config editing
alias vc='vim ~/.config/vim/vimrc'
alias vz='vim ~/Dropbox/dotfiles/zshrc'
alias sz='source ~/.zshrc'

# Safety aliases
alias tp='trash-put -v'
# alias rm='echo "This is not the command you are looking for."; false'

# ==========================================================================
# 🍎 MACOS-SPECIFIC ALIASES
# ==========================================================================

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS application shortcuts
    alias sk='open -a Skim'
fi

# ==========================================================================
# 11. CUSTOM FUNCTIONS (Cross-platform)
# ==========================================================================

# Directory listing function
d() {
    if [[ -n $1 ]]; then
        dirs "$@"
    else
        dirs -v | head -n 10
    fi
}

# File finder with cd
ff() {
    local file
    file=$(rg --files "${1:-.}" 2>/dev/null | fzf --select-1 --exit-0)
    if [[ -n "$file" ]]; then
        cd "$(dirname "$file")" || return 1
    fi
}

# PDF finder with zathura (IMPROVED: converted from alias to function with error handling)
pp() {
    local pdf
    pdf=$(rg --files 2>/dev/null | rg "\.pdf$" | fzf)
    if [[ -n "$pdf" ]]; then
        zathura "$pdf" &
    fi
}

# R file finder with vim (IMPROVED: converted from alias to function with error handling)
rr() {
    local rfile
    rfile=$(rg --files 2>/dev/null | rg "\.(R|Rmd)$" | fzf)
    if [[ -n "$rfile" ]]; then
        vim "$rfile"
    fi
}

# Git workflow function: select files, scan staged content for secrets,
# commit with a human-written subject, confirm, then push.
#
# Environment variables:
#   GZ_PROTECTED_BRANCHES     space-separated list; default "main master".
#   GZ_SECRET_SCANNER         "gitleaks" (default) or "none".
#   GZ_ALLOW_SECRET_OVERRIDE  if set to 1, enables an audited override path
#                             when the scanner finds secrets. Each override
#                             is logged to $GIT_DIR/gz-overrides.log. Do not
#                             set this permanently; set per-session only.
#
# Companion:
#   gz-scan-history  runs the scanner over the full git history.
gz() {
    # Repo guard
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo 'Error: Not a git repository' >&2
        return 1
    fi

    # Branch + protected-branch check
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    local protected_branches="${GZ_PROTECTED_BRANCHES:-main master}"
    local is_protected=0 b
    for b in ${=protected_branches}; do
        [[ "$branch" == "$b" ]] && is_protected=1
    done

    echo "Branch: $branch"
    echo ''
    echo 'Working tree status:'
    git status --short
    echo ''

    # Gather unstaged candidates (tracked-modified + untracked, deduped,
    # empties stripped). Filenames with spaces survive because (f) splits
    # only on newlines.
    local -a unstaged
    unstaged=(
        ${(f)"$(git diff --name-only 2>/dev/null)"}
        ${(f)"$(git ls-files --others --exclude-standard 2>/dev/null)"}
    )
    typeset -U unstaged
    unstaged=(${unstaged:#})

    # Interactive file selection
    local -a chosen
    if [[ ${#unstaged[@]} -gt 0 ]]; then
        if command -v fzf > /dev/null 2>&1; then
            echo 'Select files to stage (TAB multi-select, Enter confirm, Esc none):'
            chosen=(${(f)"$(printf '%s\n' "${unstaged[@]}" | fzf -m --prompt='stage> ' --height=40% --reverse)"})
        else
            echo 'Unstaged / untracked files:'
            local i=1 f
            for f in "${unstaged[@]}"; do
                printf '  %2d) %s\n' $i "$f"
                ((i++))
            done
            echo ''
            echo -n 'Select files (numbers space/comma-separated, "a" all, Enter none): '
            local sel
            read -r sel
            if [[ "$sel" == 'a' || "$sel" == 'A' ]]; then
                chosen=("${unstaged[@]}")
            elif [[ -n "$sel" ]]; then
                local -a idxs
                idxs=(${(s: :)${sel//,/ }})
                local n
                for n in "${idxs[@]}"; do
                    if [[ "$n" =~ ^[0-9]+$ ]] && (( n >= 1 && n <= ${#unstaged[@]} )); then
                        chosen+=("${unstaged[$n]}")
                    fi
                done
            fi
        fi
        chosen=(${chosen:#})
    fi

    # Stage selected files
    if [[ ${#chosen[@]} -gt 0 ]]; then
        if ! git add -- "${chosen[@]}"; then
            echo 'Error: git add failed' >&2
            return 1
        fi
    fi

    # Need something in the index at this point
    if [[ -z "$(git diff --cached --name-only)" ]]; then
        echo 'Nothing staged. Aborting.' >&2
        return 1
    fi

    # Content-based secret scan of the staged diff. Refuses on findings
    # unless GZ_ALLOW_SECRET_OVERRIDE=1 (audited). Non-destructive: on
    # refusal the index is left as-is so you can run `git reset HEAD -- <f>`
    # or edit the file and re-run gz.
    if ! _gz_secret_scan; then
        return 1
    fi

    # Summary
    echo ''
    echo '---------------------------------------------------------------'
    echo 'STAGED CHANGES'
    echo '---------------------------------------------------------------'
    git diff --cached --stat
    echo ''
    echo 'Preview (first 30 lines):'
    git --no-pager diff --cached | awk 'NR<=30'
    echo ''

    # Commit type
    echo '---------------------------------------------------------------'
    echo 'Commit type:'
    echo '  1) feat       - A new feature'
    echo '  2) fix        - A bug fix'
    echo '  3) refactor   - Code refactoring'
    echo '  4) docs       - Documentation updates'
    echo '  5) test       - Adding/updating tests'
    echo '  6) chore      - Build, config, dependencies'
    echo '  7) perf       - Performance improvements'
    echo '  8) ci         - CI/CD configuration'
    echo '  9) style      - Code style (formatting, linting)'
    echo ''
    echo -n 'Select commit type (1-9): '
    local type_choice type
    read -r type_choice
    case $type_choice in
        1) type='feat' ;;
        2) type='fix' ;;
        3) type='refactor' ;;
        4) type='docs' ;;
        5) type='test' ;;
        6) type='chore' ;;
        7) type='perf' ;;
        8) type='ci' ;;
        9) type='style' ;;
        *) echo "Invalid choice. Using 'chore'" >&2; type='chore' ;;
    esac

    local scope subject body
    echo -n 'Scope (optional, Enter to skip): '
    read -r scope
    echo -n 'Subject (short imperative summary of the change): '
    read -r subject
    if [[ -z "$subject" ]]; then
        local -a staged_now
        staged_now=(${(f)"$(git diff --cached --name-only)"})
        staged_now=(${staged_now:#})
        local -a first_five=(${staged_now[1,5]})
        subject=${(j:,:)first_five}
        if (( ${#staged_now[@]} > 5 )); then
            subject="$subject and $((${#staged_now[@]} - 5)) more files"
        fi
        echo "  (no subject given; using file list: $subject)"
    fi
    echo -n 'Body (optional, Enter to skip): '
    read -r body

    local commit_msg="$type"
    [[ -n "$scope" ]] && commit_msg="$commit_msg($scope)"
    commit_msg="$commit_msg: $subject"
    [[ -n "$body" ]] && commit_msg="$commit_msg"$'\n\n'"$body"

    # Pre-commit confirmation
    echo ''
    echo '---------------------------------------------------------------'
    echo 'Ready to commit:'
    echo "  branch:  $branch"
    echo '  files to be committed:'
    git diff --cached --name-only | sed 's/^/    - /'
    echo '  message:'
    echo "$commit_msg" | sed 's/^/    /'
    if [[ $is_protected -eq 1 ]]; then
        echo "  NOTE: '$branch' is a protected branch (see GZ_PROTECTED_BRANCHES)."
    fi
    echo '---------------------------------------------------------------'
    echo -n 'Proceed with commit? [y/N]: '
    local proceed
    read -r proceed
    [[ "$proceed" == 'y' || "$proceed" == 'Y' ]] || { echo 'Aborted.'; return 1; }

    if ! git commit -m "$commit_msg"; then
        echo 'Error: Commit failed' >&2
        return 1
    fi

    # Push confirmation (extra-explicit on protected branches)
    local push_prompt='Push now? [y/N]: '
    [[ $is_protected -eq 1 ]] && push_prompt="About to push to protected branch '$branch'. Proceed? [y/N]: "
    echo -n "$push_prompt"
    local do_push
    read -r do_push
    if [[ "$do_push" != 'y' && "$do_push" != 'Y' ]]; then
        echo "Commit made on '$branch'. Not pushed."
        return 0
    fi

    if git push; then
        echo "Successfully pushed '$branch'."
    else
        echo 'Error: Push failed' >&2
        return 1
    fi
}

# Content-based secret scan of the staged index. Called from gz.
# Returns 0 if clean or override accepted; 1 if findings and no override.
_gz_secret_scan() {
    local scanner="${GZ_SECRET_SCANNER:-gitleaks}"
    if [[ "$scanner" == 'none' ]]; then
        echo 'Secret scan disabled (GZ_SECRET_SCANNER=none).'
        return 0
    fi

    # Scanner missing: degraded mode with filename-only heuristic plus a
    # loud warning. This is explicitly worse than content scanning and is
    # only a stopgap until gitleaks is installed.
    if ! command -v "$scanner" > /dev/null 2>&1; then
        echo '---------------------------------------------------------------'
        echo "WARNING: '$scanner' not installed. Content-based secret scanning"
        echo 'is unavailable; falling back to filename heuristic only.'
        echo ''
        echo "Install:  brew install $scanner"
        echo '(or disable this check with  export GZ_SECRET_SCANNER=none )'
        echo '---------------------------------------------------------------'
        local -a staged risky
        staged=(${(f)"$(git diff --cached --name-only)"})
        staged=(${staged:#})
        local f
        for f in "${staged[@]}"; do
            [[ "$f" == *.pub ]] && continue
            case "$f" in
                *.env|*.env.*|*credentials*|*secret*|*.pem|*.key|*id_rsa*|*id_ed25519*|*.p12|*.pfx)
                    risky+=("$f")
                    ;;
            esac
        done
        if [[ ${#risky[@]} -gt 0 ]]; then
            echo 'Filename heuristic flagged:'
            local r
            for r in "${risky[@]}"; do echo "  - $r"; done
            echo -n 'Continue without content scan? [y/N]: '
            local ok
            read -r ok
            [[ "$ok" == 'y' || "$ok" == 'Y' ]] || { echo 'Aborted.'; return 1; }
        fi
        return 0
    fi

    # gitleaks: prefer the newer `git --staged` subcommand, fall back to
    # the older `protect --staged` if present. Reads .gitleaks.toml and
    # .gitleaksignore from the repo root automatically.
    local -a gl_cmd
    if gitleaks git --help > /dev/null 2>&1; then
        gl_cmd=(gitleaks git --staged --no-banner)
    elif gitleaks protect --help > /dev/null 2>&1; then
        gl_cmd=(gitleaks protect --staged --no-banner)
    else
        echo 'gitleaks present but neither "git" nor "protect" subcommand works.' >&2
        echo 'Check gitleaks version; aborting.' >&2
        return 1
    fi

    echo 'Scanning staged changes for secrets (gitleaks)...'
    if "${gl_cmd[@]}"; then
        return 0
    fi

    # Findings. Refuse by default.
    echo ''
    echo '==============================================================='
    echo 'SECRET SCAN: gitleaks flagged potential credentials above.'
    echo '==============================================================='
    echo 'Options:'
    echo '  1) Unstage and fix (preferred):'
    echo '       git reset HEAD -- <file>'
    echo '       edit out the secret; if it was real, rotate it'
    echo '       re-run gz'
    echo ''
    echo '  2) Confirmed false positive:'
    echo '       add the fingerprint reported by gitleaks to .gitleaksignore'
    echo '       (or a rule exception to .gitleaks.toml), commit that file,'
    echo '       then re-run gz'
    echo ''
    echo '  3) Audited override (last resort):'
    echo '       export GZ_ALLOW_SECRET_OVERRIDE=1   # this shell only'
    echo '       re-run gz; a reason is required and will be appended to'
    echo '       $(git rev-parse --git-dir)/gz-overrides.log'
    echo '==============================================================='

    if [[ "$GZ_ALLOW_SECRET_OVERRIDE" != '1' ]]; then
        echo 'Aborted. Index left unchanged.' >&2
        return 1
    fi

    echo ''
    echo 'Override path enabled. A reason is required and will be logged.'
    echo -n 'Reason (>= 10 chars, describing why this commit is safe): '
    local reason
    read -r reason
    if (( ${#reason} < 10 )); then
        echo 'Reason too short. Aborted.' >&2
        return 1
    fi

    local logfile
    logfile="$(git rev-parse --git-dir)/gz-overrides.log"
    {
        echo '---'
        echo "timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
        echo "user: ${USER:-unknown}"
        echo "branch: $(git rev-parse --abbrev-ref HEAD)"
        echo 'staged_files:'
        git diff --cached --name-only | sed 's/^/  - /'
        echo "reason: $reason"
    } >> "$logfile"
    echo "Override logged to $logfile"
    return 0
}

# Scan the full git history for secrets. Complements gz, which only scans
# the staged diff. Run in a new clone, after merging external branches, or
# on a schedule.
gz-scan-history() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo 'Not a git repository.' >&2
        return 1
    fi
    local scanner="${GZ_SECRET_SCANNER:-gitleaks}"
    if ! command -v "$scanner" > /dev/null 2>&1; then
        echo "$scanner not installed. Try: brew install $scanner" >&2
        return 1
    fi
    echo "Scanning full git history with $scanner..."
    # Newer gitleaks uses `git` without --staged to scan history; older
    # versions use `detect`.
    if gitleaks git --help > /dev/null 2>&1; then
        gitleaks git --no-banner
    else
        gitleaks detect --no-banner
    fi
}

# ==========================================================================
# 🍎 MACOS-SPECIFIC FUNCTIONS
# ==========================================================================

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mathematica script runner (macOS only) - IMPROVED: added error handling
    mma() {
        if [[ -z "$1" ]]; then
            echo "Usage: mma <script.wl>" >&2
            return 1
        fi
        if [[ ! -f "$1" ]]; then
            echo "Error: File '$1' not found" >&2
            return 1
        fi
        /Applications/Mathematica.app/Contents/MacOS/WolframKernel -script "$1"
    }
fi

# ==========================================================================
# 12. EXTERNAL TOOL INTEGRATION
# ==========================================================================

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# XQuartz DISPLAY variable for Docker GUI apps (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ -z "$DISPLAY" ]]; then
        export DISPLAY=:0
    fi
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# alias to log claude sessions
#
alias claudelog='mkdir -p ~/claude_sessions/$(date +%Y-%m-%d) && script ~/claude_sessions/$(date +%Y-%m-%d)/session_$(date +%H%M%S).log claude'

alias qq='qutebrowser &'

export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

# ZZCOLLAB Navigation Functions (added by navigation_scripts.sh)
# These allow one-letter navigation from anywhere in your project

# Find project root (looks for DESCRIPTION file)
_zzcollab_root() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/DESCRIPTION" ]] || [[ -f "$dir/.zzcollab_project" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Navigation functions (z-prefixed to avoid single-letter collisions)
za() { local root=$(_zzcollab_root); [[ -n "$root" ]] && cd "$root/analysis" || echo "Not in ZZCOLLAB project"; }
zw() { local root=$(_zzcollab_root); [[ -n "$root" ]] && cd "$root/analysis/data/raw_data" || echo "Not in ZZCOLLAB project"; }
zy() { local root=$(_zzcollab_root); [[ -n "$root" ]] && cd "$root/analysis/data/derived_data" || echo "Not in ZZCOLLAB project"; }
zf() { local root=$(_zzcollab_root); [[ -n "$root" ]] && cd "$root/analysis/figures" || echo "Not in ZZCOLLAB project"; }
zt() { local root=$(_zzcollab_root); [[ -n "$root" ]] && cd "$root/analysis/data" || echo "Not in ZZCOLLAB project"; }
zs() { local root=$(_zzcollab_root); [[ -n "$root" ]] && cd "$root/analysis/scripts" || echo "Not in ZZCOLLAB project"; }
zp() { local root=$(_zzcollab_root); [[ -n "$root" ]] && cd "$root/analysis/report" || echo "Not in ZZCOLLAB project"; }
zr() { local root=$(_zzcollab_root); [[ -n "$root" ]] && cd "$root/R" || echo "Not in ZZCOLLAB project"; }
z0() { local root=$(_zzcollab_root); [[ -n "$root" ]] && cd "$root" || echo "Not in ZZCOLLAB project"; }
zm() { local root=$(_zzcollab_root); [[ -n "$root" ]] && cd "$root/man" || echo "Not in ZZCOLLAB project"; }
ze() { local root=$(_zzcollab_root); [[ -n "$root" ]] && cd "$root/tests" || echo "Not in ZZCOLLAB project"; }
zo() { local root=$(_zzcollab_root); [[ -n "$root" ]] && cd "$root/docs" || echo "Not in ZZCOLLAB project"; }
zc() { local root=$(_zzcollab_root); [[ -n "$root" ]] && cd "$root/archive" || echo "Not in ZZCOLLAB project"; }
zg() { local root=$(_zzcollab_root); [[ -n "$root" ]] && cd "$root/vignettes" || echo "Not in ZZCOLLAB project"; }

# Run make targets from any subdirectory (defaults to "make r")
mr() {
    local root=$(_zzcollab_root)
    if [[ -z "$root" ]]; then
        echo "Not in ZZCOLLAB project"
        return 1
    fi
    if [[ ! -f "$root/Makefile" ]]; then
        echo "No Makefile in project root: $root"
        return 1
    fi
    make -C "$root" "${@:-r}"
}

# List navigation shortcuts
nav() {
    echo "ZZCOLLAB Navigation Shortcuts:"
    echo "  z0 → project root"
    echo "  za → analysis/"
    echo "  zt → analysis/data/"
    echo "  zw → analysis/data/raw_data/"
    echo "  zy → analysis/data/derived_data/"
    echo "  zs → analysis/scripts/"
    echo "  zp → analysis/report/"
    echo "  zf → analysis/figures/"
    echo "  zr → R/"
    echo "  zm → man/"
    echo "  ze → tests/"
    echo "  zo → docs/"
    echo "  zc → archive/"
    echo "  zg → vignettes/"
    echo ""
    echo "Make Commands (from any subdirectory):"
    echo "  mr        → make r (start container)"
    echo "  mr test   → make test"
    echo "  mr [target] → make [target]"
}
# End ZZCOLLAB Navigation Functions


export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export ZZEDC_TEST_BACKENDS="sqlite,duckdb,postgresql"
export ZZEDC_TEST_PG_HOST="localhost"
export ZZEDC_TEST_PG_DB="zzedc_test"
export ZZEDC_TEST_PG_USER="$USER"
export ZZEDC_TEST_PG_PASSWORD=""
export PATH="/Applications/Ghostty.app/Contents/MacOS:$PATH"
