#!/bin/bash

# ==============================================================================
# Script: create_users.sh
# Beskrivning: Skapar användare, mappar och welcome.txt enligt strikta krav.
# ==============================================================================

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

    # Kontrollera om användaren redan finns (så inte skriptet kraschar vid omkörning)
    if id "$user" &>/dev/null; then
        echo "Användaren $user finns redan. Hoppar över."
        continue
    fi

    # Skapa användaren med hemkatalog
    useradd -m "$user"

    # Sätt sökväg till hemkatalog
    home="/home/$user"

    # Skapa undermappar
    mkdir -p "$home/Documents"
    mkdir -p "$home/Downloads"
    mkdir -p "$home/Work"

    # Sätt rättigheter på mapparna (Endast ägaren kan redigera och läsa)
    chmod 700 "$home/Documents"
    chmod 700 "$home/Downloads"
    chmod 700 "$home/Work"

    # Skapa välkomstfil med personligt meddelande (Första raden)
    echo "Välkommen $user" > "$home/welcome.txt"

    # Lista ANDRA användare på systemet (filtrerar bort den nyskapade användaren)
    echo "Andra användare på systemet:" >> "$home/welcome.txt"
    cut -d: -f1 /etc/passwd | grep -v "^$user$" >> "$home/welcome.txt"

    # Sätt rättigheter på välkomstfilen (Endast ägaren kan läsa/skriva)
    chmod 600 "$home/welcome.txt"

    # Sätt ägarskap SPECIFIKT på de filer och mappar vi skapat
    chown "$user:$user" "$home/welcome.txt"
    chown "$user:$user" "$home/Documents" "$home/Downloads" "$home/Work"

done

echo "Alla användare skapades klart."
