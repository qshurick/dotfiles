# ########################################################################### #
# ZSH configuration                                                           #
# ########################################################################### #

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# ########################################################################### #
# Other scripts                                                               #
# ########################################################################### #

source ./docker-database.zsh

# ########################################################################### #
# custom git functions                                                        #
# ########################################################################### #

function reset_git() {
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519.github
    ssh -T git@github.com
}

# fixup commits to last known change
function git_auto_fixup_files() {
    local usePatch=""
    local commitHash

    if (( $# == 0 )); then
        usePatch='--patch'
    fi

    for file in $(git status --short | awk '{ print $2; }')
    do
        commitHash=`git_find_latest_commit_for_file "$file"`
        git add ${usePatch} ${file} && git commit --fixup ${commitHash}
    done
}

function git_find_latest_commit_for_file() {
    local file=$1
    local count=$(git log --oneline "$file" | wc -l)
    local commitHash

    if (( $count == 1 )); then
        commitHash=$(git log --oneline "$file" | awk '{ print $1 }')
    else
        commitHash=`select_commit_for_file "$file"`
    fi

    echo $commitHash
    return
}

function select_commit_for_file() {
    local file=$1
    local IFS=$'\n'
    setopt sh_word_split
    local COLUMNS=1
    local commits=$(git log --oneline "$file" | head -5)
    local PS3="Where should one fixup ${file}? #"
    select commit in $commits; do
        if [ x"$commit" != x"" ]; then
            echo $commit | awk '{ print $1 }'
            return
        fi
    done
}

alias gfixup="git_auto_fixup_files"
alias gqfixup="git_auto_fixup_files 1"

