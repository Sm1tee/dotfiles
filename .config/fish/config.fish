if status is-interactive
set fish_greeting
    # Commands to run in interactive sessions can go here


starship init fish | source
zoxide init fish | source
mcfly init fish | source

alias g='gemini'
alias q='paru'
alias l='lsd -ll'
alias cd='z'
alias c='wl-copy'
alias rm='trash-put'



end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/smitee/.lmstudio/bin

# Created by `pipx` on 2025-06-20 21:46:31
set PATH $PATH /home/smitee/.local/bin
