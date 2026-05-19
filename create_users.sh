#!/bin/bash

# ==========================================
# Script: create_users.sh
# Beskrivning:
# Skapar användare, mappar och welcome.txt
# ==========================================

# Kontrollera om scriptet körs som root
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Du måste köra scriptet som root."
    exit 1
fi

# Kontrollera att minst en användare skickats in
if [ $# -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 ..."
    exit 1
fi

# Loopar igenom alla användarnamn
for user in "$@"
do
    echo "Skapar användare: $user"

    # Skapa användaren med hemkatalog
    useradd -m "$user" 2>/dev/null
if id "$user" &>/dev/null; then
    echo "Användaren $user finns redan"
fi
    # Sätt sökväg till hemkatalog
    home_dir="/home/$user"

    # Skapa undermappar
    mkdir -p "$home_dir/Documents"
    mkdir -p "$home_dir/Downloads"
    mkdir -p "$home_dir/Work"

    # Sätt rättigheter:
    # Endast ägaren får läsa/skriva/öppna
    chmod 700 "$home_dir/Documents"
    chmod 700 "$home_dir/Downloads"
    chmod 700 "$home_dir/Work"
    chmod 700 "$home_dir"
    # Skapa welcome.txt
    welcome_file="$home_dir/welcome.txt"

    echo "Välkommen $user!" > "$welcome_file"
    echo "" >> "$welcome_file"
    echo "Andra användare på systemet:" >> "$welcome_file"

    # Lista alla användare på systemet
    cut -d: -f1 /etc/passwd >> "$welcome_file"

    # Ägarskap
    chown -R "$user:$user" "$home_dir"

    echo "Klar med användare: $user"
    echo "-----------------------------"

done

echo "Alla användare skapades klart."
