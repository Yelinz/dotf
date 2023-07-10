#!/bin/bash
read -p 'Email: ' email 

# general dependencies
sudo apt-get install git curl libfuse2 ripgrep

# nvim setup


# git setup
git config --global core.editor "vim"
git config --global user.name "Yelin Zhang"
git config --global user.email $email
