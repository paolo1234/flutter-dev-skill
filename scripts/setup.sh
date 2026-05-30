#!/bin/bash

echo "========================================================"
echo "Flutter Forge - Environment Setup Check"
echo "========================================================"
echo ""

# Check Git
if ! command -v git &> /dev/null; then
    echo "[X] Git non trovato. Installalo tramite il tuo package manager (es: sudo apt install git o brew install git)"
    exit 1
else
    echo "[OK] Git è già installato."
fi

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "[X] Flutter SDK non trovato."
    echo "Vuoi scaricare Flutter e installarlo in ~/flutter? (s/n)"
    read -r install_flutter
    if [ "$install_flutter" = "s" ]; then
        cd ~ || exit
        git clone https://github.com/flutter/flutter.git -b stable
        echo "ATTENZIONE: Aggiungi export PATH=\"\$PATH:\$HOME/flutter/bin\" al tuo ~/.bashrc o ~/.zshrc"
        echo "Dopo aver aggiornato il file, ricarica il terminale ed esegui 'flutter doctor'."
    else
        echo "Setup interrotto. Installa Flutter da https://flutter.dev/"
        exit 1
    fi
else
    echo "[OK] Flutter SDK trovato."
    echo ""
    echo "Esecuzione di flutter doctor..."
    flutter doctor
fi

echo ""
echo "========================================================"
echo "Setup completato! L'ambiente è pronto per Flutter Forge."
echo "========================================================"
