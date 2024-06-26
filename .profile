#!/bin/sh -l

if command -v nvim > /dev/null
then
	export VISUAL=nvim 
elif command -v vim > /dev/null
then
	export VISUAL=vim
elif command -v vi > /dev/null
then
	export VISUAL=vi
fi

if command -v ex > /dev/null
then
	export EDITOR=ex 
elif command -v ed > /dev/null
then
	export EDITOR=ed
fi
export FCEDIT="$VISUAL"

if command -v less > /dev/null
then
	export PAGER=less
elif command -v more > /dev/null
then
	export PAGER=more
fi

if test -r "$HOME"/.shrc
then
	export ENV="$HOME"/.shrc
fi

PATH=$HOME/.nodenv/bin:$HOME/.pyenv/bin:$HOME/.local/bin/:$PATH
export MANPATH="$HOME"/.local/share/man:
