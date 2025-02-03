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
	if test -d "$i"
	then
		append_path "$i"
	fi
done
export PATH

export XDG_CONFIG_HOME="$HOME/.config/"
export XDG_CACHE_HOME="$HOME/.cache/"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state/"

for i in nvim vim vi
do
	if command -v "$i" > /dev/null
	then
		export VISUAL="$i"
		break
	fi
done

for i in ex ed
do
	if command -v "$i" > /dev/null
	then
		export EDITOR=$i
	fi
done

for i in less more
do
	if command -v "$i" > /dev/null
	then
		export PAGER=less
	fi
done

if test -f "$HOME"/.cargo/env
then
	. "$HOME/.cargo/env"
fi

