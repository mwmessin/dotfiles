
NODE_PATH=/usr/local/lib/node_modules
export ANDROID_SDK_HOME='/Applications/Utilities/Android/sdk'

PATH=$PATH:$HOME/.rvm/bin:$NODE_PATH:$ANDROID_SDK_HOME/platform-tools

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Colors
export black=`echo -e "\x1b[0;30m"`
export red=`echo -e "\x1b[0;31m"`
export green=`echo -e "\x1b[0;32m"`
export yellow=`echo -e "\x1b[0;33m"`
export blue=`echo -e "\x1b[0;34m"`
export magenta=`echo -e "\x1b[0;35m"`
export cyan=`echo -e "\x1b[0;36m"`
export white=`echo -e "\x1b[0;37m"`
export endcolor=`echo -e "\x1b[m"`

color() {
  echo -e "\e[38;5;$1m"
}

alias ct='colortable'
colortable() {
  for fgbg in 38 48 ; {
    for color in {0..256} ; {
      echo -en "\e[${fgbg};5;${color}m ${color}\t\e[0m"
      [[ $((($color + 1) % 10)) == 0 ]] && echo
    }
    echo
  }
}

colordiff() {
  cat | replace \
    "^(\+) (.*)$" "$green\1$white \2$endcolor" \
    "^(\-) (.*)$" "$red\1$black \2$endcolor"
}

# Command Prompt
PS1="\n\n@ \w/ \$(color 54)\$(gbn) $black\[\@ \d\]$endcolor\n> "

# Globbing
shopt -s globstar

# Editor
export EDITOR='subl'

alias subl='/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl'
alias s='subl'

# Filesys
alias f='finder'
finder() {
	find . -iname "*$1*"
}

fuzzypath() {
  if [ -z $2 ]
  then
    COMPREPLY=( `ls` )
  else
    DIRPATH=`echo "$2" | gsed 's|[^/]*$||'`
    BASENAME=`echo "$2" | gsed 's|.*/||'`
    FILTER=`echo "$BASENAME" | gsed 's|.|\0.*|g'`
    COMPREPLY=( `ls $DIRPATH | grep -i "^$FILTER" | gsed "s|^|$DIRPATH|g"` )
  fi
}

complete -o nospace -o filenames -F fuzzypath cd ls cat rm cp mv

alias ~='cd ~; ls -a'
alias .='ls -a'
alias ..='cd ..; ls -a'
alias ...='cd ../..; ls -a'
alias ....='cd ../../..; ls -a'
alias -- -='cd -; ls -a'

# Net
post() {
  curl --data "$2" "$1"
}

get() {
  curl "$1"
}

delete() {
  curl -X DELETE "$1"
}

alias inet='ifconfig | grep inet'

# Text
alias re='replace'
replace() {
  local cmd=""
  local end="g"
  while [ $# -gt 0 ]
  do
    [ "$1" = "-i" ] && end="${end}I" && shift && continue
    [ "$1" = "-m" ] && cmd="${cmd}1h;1!H;\${;g;" && end="${end};p}" && shift && continue

    if [ -z "$2" ]
    then
      cmd="${cmd}s/$1/$black[$yellow\0$black]$endcolor/${end};"
      shift
    else
      cmd="${cmd}s/$1/$2/${end};"
      shift
      shift
    fi

    end="g"
  done
  gsed -rn "${cmd}p"
}

# System
alias \?='defined'
defined() {
  alias $1 2>/dev/null || declare -f $1 || which $1
}

pid() {
  ps aux | grep $1 | grep -v grep | awk '{ print $2 }'
}

# Terminal
export up=`echo -e "\x1b[1A"`
export down=`echo -e "\x1b[1B"`
export left=`echo -e "\x1b[1D"`
export right=`echo -e "\x1b[1C"`

tab() {
  osascript \
    -e 'tell application "Terminal" to activate' \
    -e 'tell application "System Events" to tell process "Terminal" to keystroke "t" using command down' \
    -e "tell application \"Terminal\" to do script \"$1\" in selected tab of the front window"
}

tabname() {
  printf "\e]1;$1\a"
}

alias c='clear'

# Profile
alias rb='source ~/.bashrc'
alias pf='subl ~/.bashrc'

# Browser
alias chrome='open /Applications/Google\ Chrome.app'

# Server
alias ac='subl /etc/apache2/httpd.conf'
alias dr='cd /Library/WebServer/Documents/'

# Git
alias gb='git branch'
alias gbn='git rev-parse --abbrev-ref HEAD'
alias gd='git diff'
alias gcb='git checkout -b'
alias gcm='git commit -am'
alias gs='git stash'
alias gt='gco sandbox && grh stable && gpu -f'
alias gsa='git stash apply'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gpo='git fetch && git pull origin'
alias gu='git fetch && git pull'
alias gpu='git push origin $(gbn)'
alias grh='git reset --hard'
alias grv='git revert -m 1'
alias grb='git rebase -i'


