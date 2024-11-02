
typeset -U PATH path

path=( $HOME/.local/bin $path )

if test -d /usr/lib/flatpak-xdg-utils/
then
	path=( /usr/lib/flatpak-xdg-utils $path )
fi

if test -d "$HOME/.local/opt/go/bin"
then
	path=( "$HOME/.local/opt/go/bin" $path )
fi

if test -d "$HOME/go/bin"
then
	path=( "$HOME/go/bin" $path )
fi

export PATH
