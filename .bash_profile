#!/bin/bash -l

for i in  ~/.profile ~/.bashrc
do
	if test -f "$i"
	then
		. "$i"
	fi
done
