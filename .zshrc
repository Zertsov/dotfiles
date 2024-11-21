###########
# Aliases #
###########
echo "> setting aliases"
source ~/.alias

#################
# Prompt config #
#################
git_prompt () {
        git rev-parse --is-inside-work-tree &> /dev/null || return
        local branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
        git describe --all --exact-match HEAD 2> /dev/null || \
        git rev-parse --short HEAD 2> /dev/null || \
        echo '(unknown)')"
        local statuses=()
        repoURL="$(git config --get remote.origin.url)"
        if grep --color=auto -q 'chromium/src.git' <<< "${repoURL}"
        then
                statuses+='*'
        else
                if ! $(git diff --quiet --ignore-submodules --cached)
                then
                        statuses+=('uncommitted')
                fi
                if ! $(git diff-files --quiet --ignore-submodules --)
                then
                        statuses+=('unstaged')
                fi
                if [ -n "$(git ls-files --others --exclude-standard)" ]
                then
                        statuses+=('untracked')
                fi
                if $(git rev-parse --verify refs/stash &>/dev/null)
                then
                        statuses+=('stashed')
                fi
        fi
        echo -e "${1}${branchName}${2} [ ${statuses[@]} ]"
}

setopt PROMPT_SUBST
PS1=$'\n%{\C-[[38;5;166m%}%n%{\C-[[37m%} in %{\C-[[38;5;64m%}%~$(git_prompt "%{\C-[[37m%} branch: %{\C-[[38;5;61m%}" "%{\C-[[38;5;33m%}")\n%{\C-[[37m%}→ %{\C-[(B\C-[[m%}'

####################
# Custom functions #
####################
echo "> setting custom functions"
source ~/.funcs

########
# Misc #
########
export PNPM_HOME="/Users/mitch/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

#######
# FNM #
#######
eval "$(fnm env --use-on-cd)"
