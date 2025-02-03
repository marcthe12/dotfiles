#!/usr/bin/zsh -i

zmodload zsh/zprof

bindkey -v
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

HISTFILE="$HOME/.histfile"
HISTSIZE=1000
SAVEHIST=1000
setopt hist_ignore_all_dups hist_save_no_dups hist_reduce_blanks share_history extended_history

fpath=("$HOME/.zfunc" "$HOME/.zfunc/zsh-completions/src" $fpath)

alias diff='diff --color=auto'
alias ls='ls -F --color=auto'
alias grep='grep --color=auto'
alias sudo='sudo '
alias run0='run0 '

autoload -Uz compinit promptinit
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' complete-options true
zstyle ':completion:*' rehash true
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands
compinit

compdef dotfiles=git

bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

promptinit
prompt marc

setopt no_clobber
setopt extendedglob

setopt auto_cd auto_pushd pushd_silent pushd_to_home pushd_ignore_dups
pushd .

autoload -Uz run-help
(( ${+aliases[run-help]} )) && unalias run-help
alias help=run-help

autoload -Uz e v p bell


