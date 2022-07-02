if status is-interactive
    alias reboot='doas reboot'
    alias poweroff='doas poweroff'

    setxkbmap -option "caps:escape"
end

set fish_greeting
ssh-add $HOME/.ssh/github.com.key >/dev/null 2>&1
