# MWM

# Colors
color() {
	export $1=`echo -e "\x1b[$2m"`
	alias $1="echo \$$1"
}

color black '0;30'
color red '0;31'
color green '0;32'
color yellow '0;33'
color blue '0;34'
color magenta '0;35'
color cyan '0;36'
color white '0;37'
color endcolor ''

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

# Text
alias e='echo'
alias lc='wc -l'
alias cols='column -t -s'

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

md5() {
	md5sum <<< $1 | cut -f1 -d ' '
}

downcase() {
	echo "$1" | tr '[:upper:]' '[:lower:]'
}

upcase() {
	echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Sets
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

factorial() { 
	(echo 1; seq $1) | paste -s -d\* | bc
}

max() {
	[ $1 -gt $2 ] && echo $1 || echo $2
}

min() {
	[ $1 -lt $2 ] && echo $1 || echo $2
}

# Control
each() {
	while read line; do
		for cmd in "$@"; {
			$cmd $line
		}
	done
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
		DIRPATH=`echo "$2" | gsed "s|~|$HOME|" | gsed 's|[^/]*$||'`
		BASENAME=`echo "$2" | gsed "s|~|$HOME|" | gsed 's|.*/||'`
		FILTER=`echo "$BASENAME" | gsed 's|.|\0.*|g'`
		COMPREPLY=( `ls -a $DIRPATH | grep -i "$FILTER" | gsed "s|^|$DIRPATH|g"` )
	fi
}
complete -o nospace -o filenames -F fuzzypath cat cd cp mv ls rm s

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

alias o='open'

# Net
post() {
	curl --data "$2" "$1"
}

put() {
	curl -s "$1"
}

get() {
	curl "$1"
}

delete() {
	curl -X DELETE "$1"
}

alias port='lsof -i'
alias inet='ifconfig | grep "inet "'
alias exip='dig +short myip.opendns.com @resolver1.opendns.com'
alias hosts='s /private/etc/hosts'

google() {
	chrome "http://www.google.com/#q=$1"
}

# System
alias cpus='sysctl -n hw.ncpu'

alias \?='defined'
defined() {
	for ask in "$@"; {
		alias $ask 2>/dev/null || declare -f $ask || which $ask
	}
}

p() {
	ps aux | head -1
	ps aux | grep $1 | grep -v grep
}

pid() {
	ps aux | grep $1 | grep -v grep | awk '{ print $2 }'
}

command_not_found_handle() {
	if [ -f $1 ] ; then
		cat $1
	elif [ -d `echo "$1" | sed 's|/$||'` ] ; then
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

alias als='compgen -a | each "alias"'

# Terminal
alias h='searchhistory'
searchhistory() {
	history | grep "$1"
}

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
alias sbrc='source ~/.bashrc'
alias brc='subl ~/.bashrc'

# Browsers
alias chrome='open -a /Applications/Google\ Chrome.app'
alias firefox='open -a /Applications/Firefox.app'
alias safari='open -a /Applications/Safari.app'

# Art
alias photoshop='open -a /Applications/Adobe\ Photoshop*/Adobe\ Photoshop*.app'

# Server
alias ac='subl /etc/apache2/httpd.conf'
alias dr='cd /Library/WebServer/Documents; .'
alias ss='python -m SimpleHTTPServer'

# Git
alias gpf='subl ~/.gitconfig'
alias gb='git branch'
alias gpr='hub pull-request -b'
alias gbn='git rev-parse --abbrev-ref HEAD 2>/dev/null'
alias gbcl='gb | grep -v -e \* -e master | each "gb -D"'
alias gup='[ -n "`gbn`" ] && [ 0 -eq $(git rev-list $(gbn)..origin/$(gbn) --count) ] && [ 0 -eq $(git rev-list origin/$(gbn)..$(gbn) --count) ]'
alias gd='git diff'
alias gdf='gd --name-only'
alias gco='git checkout'
alias gcb='gco -b'
alias gcf='git ls-files -u | cut -f 2 | sort -u'
alias gcm='git commit -am'
alias gm='git merge'
alias gs='git stash'
alias gsa='gs apply'
alias gl='git --no-pager log -n 40 -w --reverse --pretty=tformat:"%C(black)%cr%Creset|%C(yellow)%an%Creset|%s %C(blue)%h%Creset%C(magenta)%d%Creset" | column -t -s "|"'
alias gst='git status'
alias gcp='git cherry-pick'
alias gcl='git clean -f -d'
alias gpo='git fetch && git pull origin'
alias gu='git fetch --all && git pull origin $(gbn)'
alias gpu='git push origin $(gbn)'
alias gr='git reset'
alias grh='gr --hard'
alias grv='git revert -m 1'
alias gca='git commit --amend -a --no-edit'
alias grom='git fetch --all && git rebase origin/master'
alias grc='git rebase --continue'

gittab() {
	if [ $3 == *"--"* ]
	then
		COMPREPLY=( `ls -a` )
	else
		COMPREPLY=( `gb | gsed 's|..||' | grep -i "$2"` )
	fi
}
complete -o nospace -o filenames -F gittab gco gpo gb gm

# Command Prompt
PS1="\n\n$endcolor@ \w/ \$(gup && green || yellow)\$(gbn) $black\[\@ \d\]$endcolor\n⚡ "

# Editor
export EDITOR='subl'
export GIT_EDITOR='/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl'

alias s='subl'

# Dev
alias b='bundle'
alias redis='~/redis-*/src/redis-server'

export JAVA='/usr/bin/java'

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
