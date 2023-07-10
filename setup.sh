#!/bin/bash
cd ~
mkdir repos tools

read -p 'Email: ' email 

# general dependencies
# libfuse2 is for appimages
sudo apt-get install git curl libfuse2 ripgrep

# nvim setup


# git setup
git config --global core.editor "vim"
git config --global user.name "Yelin Zhang"
git config --global user.email $email

# node
curl -L https://bit.ly/n-install | N_PREFIX=~/tools/n bash -s -- -y
npm install -g npm yarn pnpm
