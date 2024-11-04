#!/bin/sh -l

append_path () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$1"
    esac
}

for i in "$HOME"/.local/bin "$HOME"/.local/opt/*/bin "$HOME/go/bin"
do
	if test -d "$HOME/.local/opt/go/bin"
	then
		append_path "$i"
	fi
done
export PATH


export XDG_CONFIG_HOME="$HOME/.config/"
export XDG_CACHE_HOME="$HOME/.cache/"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state/"

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
	export EDITOR=nvim 
elif command -v ed > /dev/null
then
	export EDITOR=vim
fi

if command -v less > /dev/null
then
	export PAGER=less
elif command -v more > /dev/null
then
	export PAGER=more
fi

if test -f "$HOME"/.cargo/env
then
	. "$HOME/.cargo/env"
fi

