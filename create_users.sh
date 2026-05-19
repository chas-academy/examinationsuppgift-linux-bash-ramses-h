#!/bin/bash

# ==============================================================================
# 1. GRUNDSTRUKTUR OCH BEHÖRIGHET (20p)
# ==============================================================================

# Kontrollera om användaren som kör skriptet är root (UID 0)
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Detta skript måste köras som root (Superuser)." >&2
    exit 1
fi

# Kontrollera att minst ett användarnamn skickades med som argument
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 användare1 [användare2 ...]"
    exit 1
fi

# ==============================================================================
# 2. ANVÄNDARSKAPANDE & ITERATION (20p)
# ==============================================================================

# Loopar igenom alla argument (användarnamn) som skickades till skriptet
for username in "$@"; do

    # Kontrollera om användaren redan finns för att undvika felmeddelanden
    if id "$username" &>/dev/null; then
        echo "Användaren '$username' finns redan. Hoppar över..."
        continue
    fi

    echo "Skapar användaren: $username"
    
    # Skapar användaren med en hemkatalog (-m) och sätter standard-shell till bash (-s)
    useradd -m -s /bin/bash "$username"

    # Hämta hemkatalogens sökväg dynamiskt
    USER_HOME=$(eval echo "~$username")

    # ==========================================================================
    # 3. KATALOGSTRUKTUR OCH RÄTTIGHETER (20p)
    # ==========================================================================
    
    echo " Skapar undermappar för $username..."
    # Skapar mapparna Documents, Downloads och Work i användarens hemkatalog
    mkdir -p "$USER_HOME/Documents" "$USER_HOME/Downloads" "$USER_HOME/Work"

    # Ändra ägandeskap så att den nya användaren äger sina egna mappar
    chown -R "$username:$username" "$USER_HOME/Documents" "$USER_HOME/Downloads" "$USER_HOME/Work"

    # Sätt rättigheter: Endast ägaren kan läsa, skriva och exekvera (700)
    # Detta ser till att ingen annan användare på systemet kan titta i mapparna
    chmod 700 "$USER_HOME/Documents" "$USER_HOME/Downloads" "$USER_HOME/Work"

    # ==========================================================================
    # 4. VÄLKOMSTMEDDELANDE (20p)
    # ==========================================================================
    
    echo " Genererar välkomstfil..."
    WELCOME_FILE="$USER_HOME/welcome.txt"

    # i. Första raden: Personligt välkomstmeddelande
    echo "Välkommen $username" > "$WELCOME_FILE"

    # ii. En lista på alla andra användare som redan finns i systemet
    # Vi hämtar ut alla användarnamn från /etc/passwd (kolumn 1, separerad med kolontecken)
    # Vi filtrerar bort den precis skapade användaren för att bara visa "andra" användare
    echo "Andra användare på systemet:" >> "$WELCOME_FILE"
    cut -d: -f1 /etc/passwd | grep -v "^$username$" >> "$WELCOME_FILE"

    # Sätt rätt ägare och rättigheter även på välkomstfilen
    chown "$username:$username" "$WELCOME_FILE"
    chmod 600 "$WELCOME_FILE"

    echo " Klar med $username!"
    echo "----------------------------------------"
done

echo "Alla användare har hanterats korrekt!"
