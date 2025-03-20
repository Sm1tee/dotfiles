if status is-interactive
set fish_greeting
    # Commands to run in interactive sessions can go here


starship init fish | source
zoxide init fish | source

alias q='paru'
alias l='lsd -ll'
alias cd='z'
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/smitee/.lmstudio/bin
