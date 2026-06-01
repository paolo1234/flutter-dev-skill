#!/bin/bash

echo "========================================================"
echo "Flutter Forge - Skill Installation (Antigravity IDE)"
echo "========================================================"
echo ""

# Determina le cartelle di destinazione
ANTIGRAVITY_DIR="$HOME/.gemini/config/skills/flutter-forge"
OPENCODE_DIR="$HOME/.config/opencode/skills/flutter-forge"

# Entra nella directory dello script e vai al root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR/.."

for SKILL_DIR in "$ANTIGRAVITY_DIR" "$OPENCODE_DIR"; do
    echo "Copia della skill in: $SKILL_DIR"
    echo ""

    # Crea la directory se non esiste
    mkdir -p "$SKILL_DIR"

    # Copia i file (creando le cartelle se necessario)
    cp "$ROOT_DIR/SKILL.md" "$SKILL_DIR/"

    mkdir -p "$SKILL_DIR/references"
    cp -R "$ROOT_DIR/references/"* "$SKILL_DIR/references/"

    mkdir -p "$SKILL_DIR/templates"
    cp -R "$ROOT_DIR/templates/"* "$SKILL_DIR/templates/"

    mkdir -p "$SKILL_DIR/rules"
    cp -R "$ROOT_DIR/rules/"* "$SKILL_DIR/rules/"

    mkdir -p "$SKILL_DIR/phases"
    cp -R "$ROOT_DIR/phases/"* "$SKILL_DIR/phases/"

    mkdir -p "$SKILL_DIR/state-formats"
    cp -R "$ROOT_DIR/state-formats/"* "$SKILL_DIR/state-formats/"

    mkdir -p "$SKILL_DIR/commands"
    cp -R "$ROOT_DIR/commands/"* "$SKILL_DIR/commands/"

    mkdir -p "$SKILL_DIR/docs"
    cp -R "$ROOT_DIR/docs/"* "$SKILL_DIR/docs/"

    mkdir -p "$SKILL_DIR/examples"
    # Copia examples solo se ci sono file
    if [ -d "$ROOT_DIR/examples" ] && [ "$(ls -A "$ROOT_DIR/examples")" ]; then
        cp -R "$ROOT_DIR/examples/"* "$SKILL_DIR/examples/"
    fi

    if [ $? -ne 0 ]; then
        echo "[X] Errore durante l'installazione della skill in $SKILL_DIR."
        exit 1
    fi
done

echo "[OK] Skill installata con successo su Antigravity e OpenCode!"
echo "Riavvia gli IDE o ricarica le skill per usare '/forge'."
echo ""

