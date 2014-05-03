echo "~/.profile"

export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/opt/local/bin:/opt/local/sbin::$PATH"
export NODE_PATH="/usr/local/lib/node_modules/"

# COLORS
export black=`echo -e "\x1b[0;30m"`
export red=`echo -e "\x1b[0;31m"`
export green=`echo -e "\x1b[0;32m"`
export yellow=`echo -e "\x1b[0;33m"`
export blue=`echo -e "\x1b[0;34m"`
export magenta=`echo -e "\x1b[0;35m"`
export cyan=`echo -e "\x1b[0;36m"`
export white=`echo -e "\x1b[0;37m"`
export endcolor=`echo -e "\x1b[m"`

# PROMPT
PS1="\n\n@ \w/ $black[\@ \d]$endcolor\n> "

function ask() {
	which $1 || declare -f $1 || alias $1
}

function dir() {
	cd $1
	see
}

function difference() {
	comm -23 <(echo -e "$1" | sort -u) <(echo -e "$2" | sort -u)
}

function dirtree() {
	tree | replace "(│)|(├)|(└)|(─)" "$black\0$endcolor"
}

function each() {
	while read line; do
		for f in "$@"; do
			$f $line
		done
	done
}

function finder() {
	find . -iname "*$1*"
}

function fuzz() {
	if [ -z $2 ] 
	then
		COMPREPLY=( `ls -a` )
	elif [ "$2" = "~" ] 
	then
		COMPREPLY=( `ls -a ~` )
	else
		DIRPATH=`echo "$2" | re "(.*\/)?.*" "\1"`
		BASENAME=`echo "$2" | re ".*\/(.*)" "\1"`
		FILTER=`echo "$BASENAME" | re "." "\0.*"`
		COMPREPLY=( `eval "ls -a $DIRPATH" | grep -i "^$FILTER" | gsed "s|^|$DIRPATH|g"` )
	fi
}

function inet() {
	ifconfig | grep inet
	ping www.google.com
}

function levensort() {
	local options=`echo $2 | tr '\n' ' '`
	coffee -e '
		levenshtein = (s, t) ->
			d = [] # 2D
			n = s.length
			m = t.length
			return m if n is 0
			return n if m is 0
			i = n; (d[i] = []; i--) while i >= 0
			i = n; (d[i][0] = i; i--) while i >= 0
			j = m; (d[0][j] = j; j--) while j >= 0
			i = 1; while i <= n
				s_i = s.charAt(i - 1)
				j = 1; while j <= m
					return n if i is j and d[i][j] > 4
					t_j = t.charAt(j - 1)
					cost = (if (s_i is t_j) then 0 else 1)
					mi = d[i - 1][j] + 1
					b = d[i][j - 1] + 1
					c = d[i - 1][j - 1] + cost
					mi = b if b < mi
					mi = c if c < mi
					d[i][j] = mi
					if i > 1 and j > 1 and s_i is t.charAt(j - 2) and s.charAt(i - 2) is t_j
						d[i][j] = Math.min(d[i][j], d[i - 2][j - 2] + cost) 
					++j
				++i
			return d[n][m]
		root = process.argv[4]
		options = process.argv[5].split(" ")
		options.pop()
		i = 0; while i < options.length
			console.log levenshtein(options[i], root) + " " + options[i]
			++i
	' "$1" "$options" | sort -n | cut -d " " -f 2
}

function gitpush() {
	if [ "$#" -eq 0 ]
	then
		git push -u origin master
	else
		git push -u origin "$1"
	fi
}

function replace() {
	local cmd=""
	while [ $# -gt 0 ]
	do
		local end="g"
		[ "$1" = "-i" ] && end="${end}I" && shift
		[ "$1" = "-m" ] && cmd="${cmd}1h;1!H;\${;g;" && end="${end};p}" && shift
		[ -z "$2" ] && cmd="${cmd}s/$1/$black[$yellow\0$black]$endcolor/${end};" || cmd="${cmd}s/$1/$2/${end};"
		shift
		shift
	done
	gsed -rn "${cmd}p"
}

function see() {
	if [ -d $1 ]
	then
		ls -a $1
	elif [ -f $1 ]
	then
		cat $1 | replace ".*" "  \0"
	else
		echo -e "  $1"
	fi
}

function work() {
	[ -f *.sublime-project ] && subl *.sublime-project || subl .
}

# SHORTCUTS
alias ?="ask"
alias ~="cd ~; ls -a"
alias .="ls -a"
alias ..="cd ..; ls -a"
alias ...="cd ../..; ls -a"
alias ....="cd ../../..; ls -a"
alias -- -="cd -; ls -a"
alias ac="subl /etc/apache2/httpd.conf"
alias b="make"
alias cm="git add *; git commit -m"
alias cores="grep -c processor /proc/cpuinfo"
alias db="cd ~/Dropbox/; ls -a"
alias d="dir"
alias dt="dirtree"
alias e="subl"
alias f="finder"
alias p="echo"
alias pf="subl ~/.profile"
alias pu="gitpush"
alias rb="source ~/.profile"
alias re="replace"
alias rm="rm -rf"
alias s="see"
alias st="git status"
alias ss="python -m SimpleHTTPServer 1337"
alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"
alias wk="work"

complete -o nospace -F fuzz see s dir d
