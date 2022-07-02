if status is-interactive
    alias reboot='doas reboot'
    alias poweroff='doas poweroff'

    setxkbmap -option "caps:escape"
end

ssh-add $HOME/.ssh/github.com.key >/dev/null 2>&1
