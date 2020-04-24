export ZSH_DISABLE_COMPFIX=true
export ZSH="/root/.oh-my-zsh"

ZSH_THEME="workspace"

plugins=(
  git
  terraform
  ansible
)

source $ZSH/oh-my-zsh.sh

unsetopt inc_append_history
unsetopt share_history

export GOPATH=/root/go
export PATH=$PATH:$GOPATH/bin
#export GO111MODULE=on

alias vi=vim
alias k=kubectl

ssh-add -l &>/dev/null
if [[ "$?" == 2 ]]; then
    eval `ssh-agent -s` >/dev/null
fi
