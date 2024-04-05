# Interactive access to database running in the docker container

export DEV_DEFAULT_MYSQL_USER=root
export DEV_DEFAULT_MYSQL_PASSWORD=root

function select_db_from_list() {
  local container=$1
  local dbList=$(docker exec -it $container mysql -h 127.0.0.1 -u$DEV_DEFAULT_MYSQL_USER -p$DEV_DEFAULT_MYSQL_PASSWORD -e "show databases" | grep "|" | awk '{print $2}' | tail -n +2)
  setopt sh_word_split
  local COLUMNS=1
  select dbfromlist in $dbList; do
    if [ x"$dbfromlist" != x"" ]; then
      echo $dbfromlist
      return
    fi
  done
}

function select_container_from_list() {
  local IFS=$','
  local COLUMNS=1
  setopt sh_word_split
  local list=$(docker ps --format "{{.ID}}\t{{.Image}}\t{{.Names}}" | grep -i mysql | paste -s -d ',' -)
  select container in $list; do
    if [ x"$container" != x"" ]; then
       echo $container | awk '{print $1}'
       return
    fi
  done
}

function select_last_command_from_history() {
  local IFS=$','
  local COLUMNS=1
  setopt sh_word_split
  local list=$(fc -lm "docker exec*mysql*" | awk '{$1=""; print $0}' | sed 's/^\s*//g' | paste -s -d ',' -)
  select command in $list; do
    if [ x"$command" != x"" ]; then
       echo $command
       return
    fi
  done
}

function connect_to_container_db() {
  local count=0
  local container
  local db

  if (( $# == 0 )); then
    count=$(docker ps | grep -i mysql | wc -l)
  fi

  if [[ $# -gt 0 ]]; then
    container=$1
  else
    if (( "$count" == 0 )); then
      echo "There are no container with mysql running"
      return 0
    elif (( $count == 1 )); then
      container=$(docker ps --format "{{.ID}}\t{{.Image}}\t{{.Names}}" | grep -i mysql | awk '{print $1}')
    else
      container=`select_container_from_list`
    fi
  fi

  if [[ $# -gt 1 ]]; then
    db=$2
  else
    db=`select_db_from_list "$container"`
  fi

  export Q_LAST_DB_CONNECTED="docker exec -it $container mysql -h 127.0.0.1 -u$DEV_DEFAULT_MYSQL_USER -p$DEV_DEFAULT_MYSQL_PASSWORD $db"
  print -s docker exec -it $container mysql -h 127.0.0.1 -u$DEV_DEFAULT_MYSQL_USER -p$DEV_DEFAULT_MYSQL_PASSWORD $db
  eval ${Q_LAST_DB_CONNECTED}
}

function reconnect_to_last_db() {
  if [[ "$Q_LAST_DB_CONNECTED" == "" ]]; then
    connect_to_container_db
  else
    eval ${Q_LAST_DB_CONNECTED}
  fi
}

alias db="connect_to_container_db"
alias dbr="reconnect_to_last_db"
