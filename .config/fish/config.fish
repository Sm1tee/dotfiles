alias l='lsd -ll'
alias cd='z'
alias c='wl-copy'
alias rm='trash-put'
alias q='paru'
alias g='gemini'
alias git-1='git add .'
alias git-2='git commit -m "update"'
alias git-3='git push'


# Created by `pipx` on 2025-06-20 21:46:31
set PATH $PATH /home/smitee/.local/bin

zoxide init fish | source
starship init fish | source


# string match -q "$TERM_PROGRAM" "kiro" and . (kiro --locate-shell-integration-path fish)
