# MWM

NODE_PATH=/usr/local/lib/node_modules
export ANDROID_SDK_HOME='/Applications/Utilities/Android/sdk'
export JAVA='/usr/bin/java'

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

# Command Prompt
PS1="\n\n$blue@ $endcolor\w/ $magenta\$(gbn 2>/dev/null) $black\[\@ \d\]$endcolor\n⚡ "

# Editor
export EDITOR='subl'
export GIT_EDITOR='/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl'

alias subl='/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl'
alias s='subl'

# Text
alias e='echo'

repeat() {
  printf "$1%.0s" `seq 1 $2`
}

alias re='replace'
replace() {
  local cmd=""
  local end="g"
  while [ $# -gt 0 ]; do
    [ "$1" = "-i" ] && end="${end}I" && shift && continue
    [ "$1" = "-m" ] && cmd="${cmd}1h;1!H;\${;g;" && end="${end};p}" && shift && continue

    if [ -z "$2" ]
    then
      cmd="${cmd}s|$1|$black[$yellow\0$black]$endcolor|${end};"
      shift
    else
      cmd="${cmd}s|$1|$2|${end};"
      shift
      shift
    fi

    end="g"
  done
  gsed -rn "${cmd}p"
  echo "${cmd}p"
}

each() {
  while read line; do
    for cmd in "$@"; {
      $cmd $line
    }
  done
}

alias U='union'
union() {
  sort -u $1 $2
}

alias D='difference'
difference() {
  sort $1 $2 | uniq -u
}

alias I='intersection'
intersection() {
  sort $1 $2 | uniq -d
}

alias C='complement'
complement() {
  comm -23 <(sort $1) <(sort $2)
}

# Math
∑() { # option + w
  [[ $# -eq 0 ]] && cat | awk '{ s+=$1 } END { print s }' || \
  [[ $# -eq 1 ]] && awk '{ s+=$1 } END { print s }' $1 || \
  echo "$@" | gsed 's| | \+ |g' | bc
}

π() { # option + p
  [[ $# -eq 0 ]] && cat | awk '{ s*=$1 } END { print s }' || \
  [[ $# -eq 1 ]] && awk '{ s*=$1 } END { print s }' $1 || \
  echo "$@" | gsed 's| | \* |g' | bc
}

# Filesys
shopt -s globstar

export CLICOLOR=1
export LSCOLORS=exfxcxdxbxegedabagacad

alias f='finder'
finder() {
	find . -iname "*$1*" | gsed 's|^./||'
}

alias t='tree -C'

fuzzypath() {
  if [ -z $2 ]
  then
    COMPREPLY=( `ls -a` )
  else
    DIRPATH=`echo "$2" | gsed 's|[^/]*$||'`
    BASENAME=`echo "$2" | gsed 's|.*/||'`
    FILTER=`echo "$BASENAME" | gsed 's|.|\0.*|g'`
    COMPREPLY=( `ls -a $DIRPATH | grep -i "^$FILTER" | gsed "s|^|$DIRPATH|g"` )
  fi
}
# complete -o nospace -o filenames -F fuzzypath cd ls cat rm cp mv

alias ~='cd ~; .'
alias .='ls -a -G'
alias ..='cd ..; .'

for level in {2..10} ; {
  alias ..$level="cd `repeat '../' $level`; ."
}

alias -- -='cd -; .'

alias x='extract'
extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1 ;;
      *.tar.gz)    tar xzf $1 ;;
      *.bz2)       bunzip2 $1 ;;
      *.rar)       rar x $1 ;;
      *.gz)        gunzip $1 ;;
      *.tar)       tar xf $1 ;;
      *.tbz2)      tar xjf $1 ;;
      *.tgz)       tar xzf $1 ;;
      *.zip)       unzip $1 ;;
      *.Z)         uncompress $1 ;;
      *.7z)        7z x $1 ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

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

alias inet='ifconfig | grep "inet "'

# System
alias \?='defined'
defined() {
  for ask in "$@"; {
    alias $ask 2>/dev/null || declare -f $ask || which $ask
  }
}

pid() {
  ps aux | grep $1 | grep -v grep | awk '{ print $2 }'
}

command_not_found_handle() {
  if [ -f $1 ] ; then
    cat $1
  elif [ -d `echo "$1" | gsed 's|/$||'` ] ; then
    cd $1
    .
  else
    echo "'$1' ?"
  fi
}

nulltab() {
  COMPREPLY=( `ls -a` )
}
complete -o nospace -o filenames -F nulltab -E

# Terminal
shopt -s histappend

export HISTCONTROL="ignoredups"
export HISTCONTROL=erasedups

export HISTSIZE=5000

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

# Browsers
alias chrome='open -a /Applications/Google\ Chrome.app'

# Art
alias photoshop='open -a /Applications/Adobe\ Photoshop*/Adobe\ Photoshop*.app'

# Server
alias ac='subl /etc/apache2/httpd.conf'
alias dr='cd /Library/WebServer/Documents; .'

# Git
alias gpf='subl ~/.gitconfig'
alias gb='git branch'
alias gbn='git rev-parse --abbrev-ref HEAD'
alias gbcl='gb | grep -v -e \* -e master | each "gb -D"'
alias gd='git diff'
alias gdf='gd --name-only'
alias gco='git checkout'
alias gcb='gco -b'
alias gcf='git ls-files -u | cut -f 2 | sort -u'
alias gcm='git commit -am'
alias gm='git merge'
alias gs='git stash'
alias gsa='gs apply'
alias gl='git --no-pager log -n 40 --reverse --pretty=tformat:"%C(black)%cr%x09 %C(yellow)%an%Creset %x09- %s %C(blue)%h%Creset%C(magenta)%d%Creset"'
alias gst='git status'
alias gt='gco sandbox && grh stable && gpu -f'
alias gcp='git cherry-pick'
alias gcl='git clean -f -d'
alias gpo='git fetch && git pull origin'
alias gu='git fetch && git pull'
alias gpu='git push origin $(gbn)'
alias gr='git reset'
alias grh='gr --hard'
alias grv='git revert -m 1'
alias grb='git rebase -i'

gittab() {
  COMPREPLY=( `gb | gsed 's|..||' | grep -i "$2"` )
}
complete -o nospace -o filenames -F gittab gco gpo gb gm
