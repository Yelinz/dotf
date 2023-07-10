#!/bin/bash
cd ~
mkdir repos tools

read -p 'Email: ' email 

# general dependencies
# libfuse2 is for appimages
sudo apt-get install git curl libfuse2 ripgrep ca-certificates gnupg

# nvim setup


# git setup
git config --global core.editor "vim"
git config --global user.name "Yelin Zhang"
git config --global user.email $email

# node
curl -L https://bit.ly/n-install | N_PREFIX=~/tools/n bash -s -- -y
npm install -g npm yarn pnpm

# docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$UBUNTU_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# poetry
curl -sSL https://install.python-poetry.org | python3 -
poetry completions fish > ~/.config/fish/completions/poetry.fish
set PATH $PATH /home/yz/.local/bin
