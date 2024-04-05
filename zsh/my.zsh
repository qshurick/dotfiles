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
