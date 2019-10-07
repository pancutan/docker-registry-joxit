#!/bin/bash
# Levanta RVM y un Ruby, para no tener que depender del Ruby que pudiera tener el sistema operativo,
# el cual se encuentra fuertemente acoplado al mismo
# Sergio

export PATH="$PATH:$HOME/.rvm/bin"

# Ojo source no es comando de sh, sino de bash o de zsh
source ~/.rvm/scripts/rvm

ruby miborrado.rb
