#!/bin/bash -i

case $- in
	*i*) ;;

	*)
		return
		;;
esac

if test -f ~/.shrc
then
	. ~/.shrc
fi
