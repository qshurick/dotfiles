# Start vim server and alias to add files to the current project

#---
# Firs it cheks if there is a git repo, if there is one name of the root
# directory used as a name, otherwise the name of current directory is used
#---
function get_nvim_server_name() {
    local project_path=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ $? -ne 0 ]; then
        project_path=$(pwd)
    fi
    echo $(basename "${project_path}")
    return
}

function start_nvim() {
    local server_name=`get_nvim_server_name`
    nvim --listen ${server_name} $1
}

function select_nvim() {
    local IFS=$','
    local COLUMNS=1
    local PS3="Select session or space to start new nvim: "
    setopt sh_word_split
    local server_list=$(ls ${XDG_RUNTIME_DIR:-${TMPDIR}nvim.${USER}}/*/*.*.0)
    select server_name in $server_list; do
        if [ -n $server_name ]; then
            echo $server_name
            return
        else
            return
        fi
    done
    echo $server_name
    return
}

function add_to_nvim() {
    local file_path=$1
    local server_name=`get_nvim_server_name`
    local server_path=$(ls ${XDG_RUNTIME_DIR:-${TMPDIR}nvim.${USER}}/*/*.*.0 | grep ${server_name})
    if [ -z "$server_path" ]; then
        server_path=`select_nvim`
        file_path=$(realpath "$file_path")
    fi
    if [ -z "$server_path" ]; then
        start_nvim $file_path
    else
        nvim --server "${server_path}" --remote "${file_path}"
    fi
}

alias vimp="start_nvim"
alias vima="add_to_nvim"
