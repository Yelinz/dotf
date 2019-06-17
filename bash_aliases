# ls aliases
alias l='ls'
alias ll='ls -l'
alias la='ls -lA'

# git aliases
alias gs='git status'
alias gaa='git add -A'
alias gc='git commit'
alias gca='git commit -a'
alias gcaa='git commit -a --amend'
alias gcaan='git commit -a --amend --no-edit'
alias gp='git push'
alias gpf='git push -f'
alias gpu='git push -u origin HEAD'
alias gcaanpf="gcaan && gpf"
alias gcom='git checkout master'
alias gcob='git checkout -b'

# aliases for retarded me
alias :q='exit'

# python 2 to 3
alias python='python3'
alias pip='pip3'

alias dc="docker-compose"

alias ps="pipenv shell"
