#!/bin/bash

# ==========================================
# Script: create_users.sh
# Beskrivning:
# Skapar användare, mappar och welcome.txt
# ==========================================

# Kontrollera att scriptet körs som root
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Detta skript måste köras som root."
    exit 1
fi

# Kontrollera att minst ett användarnamn skickades in
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 användare1 [användare2 ...]"
    exit 1
fi

# Loopar igenom alla användarnamn
for user in "$@"; do

    # Skapa användaren om den inte redan finns

        useradd -m "$user"
    

    # Sätt sökväg till hemkatalog
    home="/home/$user"

    # Skapa undermappar
    mkdir -p "$home/Documents"
    mkdir -p "$home/Downloads"
    mkdir -p "$home/Work"

    # Sätt rättigheter
    chmod 700 "$home/Documents"
    chmod 700 "$home/Downloads"
    chmod 700 "$home/Work"

    # Skapa welcome.txt
    echo "Välkommen $user" > "$home/welcome.txt"

    # Lista användare på systemet
    echo "Andra användare på systemet:" >> "$home/welcome.txt"
    cut -d: -f1 /etc/passwd >> "$home/welcome.txt"

    # Sätt ägarskap
    chown -R "$user:$user" "$home"

done

# Klart
echo "Alla användare skapades klart."
