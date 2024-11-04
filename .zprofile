#!zsh -l

if test -f "$HOME"/.profile
then
	emulate sh -c '. $HOME/.profile'
fi

