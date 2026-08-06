#!/usr/bin/env bash
# Rofi script mode — Quick Links
# Formato: nombre\0icon\x1ficono_tema

declare -A LINKS=(
    ["Gmail"]="https://mail.google.com/"
    ["YouTube"]="https://www.youtube.com/"
    ["GitHub"]="https://www.github.com/"
    ["Reddit"]="https://www.reddit.com/"
    ["X / Twitter"]="https://www.x.com/"
    ["LinkedIn"]="https://www.linkedin.com/"
    ["HackTheBox"]="https://www.hackthebox.com/"
    ["TryHackMe"]="https://tryhackme.com/"
)

declare -A ICONS=(
    ["Gmail"]="internet-mail"
    ["YouTube"]="youtube"
    ["GitHub"]="github"
    ["Reddit"]="reddit"
    ["X / Twitter"]="twitter"
    ["LinkedIn"]="linkedin"
    ["HackTheBox"]="applications-games"
    ["TryHackMe"]="applications-games"
)

if [[ -z "$1" ]]; then
    for name in Gmail YouTube GitHub Reddit "X / Twitter" LinkedIn HackTheBox TryHackMe; do
        printf "%s\0icon\x1f%s\n" "$name" "${ICONS[$name]}"
    done
else
    url="${LINKS[$1]}"
    [[ -n "$url" ]] && xdg-open "$url" &
fi
