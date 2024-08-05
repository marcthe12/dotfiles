
typeset -U PATH path

path=( $HOME/.local/bin $HOME/.local/opt/nvim-linux64/bin $path )

if test -d /usr/lib/flatpak-xdg-utils/
then
	path=( /usr/lib/flatpak-xdg-utils $path )
fi

export PATH
