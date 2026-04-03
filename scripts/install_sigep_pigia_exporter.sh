#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /path/to/SIGEP"
  exit 1
fi

SIGEP_PATH="$1"
CONSOLE_PATH="$SIGEP_PATH/routes/console.php"
EXPORT_ROUTE_PATH="$SIGEP_PATH/routes/pigia_export_console.php"
TEMPLATE_PATH="$(cd "$(dirname "$0")" && pwd)/templates/sigep_pigia_export_console.php"
INCLUDE_LINE="require __DIR__.'/pigia_export_console.php';"

if [[ ! -d "$SIGEP_PATH" ]]; then
  echo "Erreur: dossier introuvable -> $SIGEP_PATH"
  exit 1
fi

if [[ ! -f "$CONSOLE_PATH" ]]; then
  echo "Erreur: fichier introuvable -> $CONSOLE_PATH"
  exit 1
fi

if [[ ! -f "$TEMPLATE_PATH" ]]; then
  echo "Erreur: template introuvable -> $TEMPLATE_PATH"
  exit 1
fi

cp "$TEMPLATE_PATH" "$EXPORT_ROUTE_PATH"

if ! grep -Fq "$INCLUDE_LINE" "$CONSOLE_PATH"; then
  printf "\n%s\n" "$INCLUDE_LINE" >> "$CONSOLE_PATH"
fi

echo "Installation terminée."
echo "Fichier export ajouté: $EXPORT_ROUTE_PATH"
echo "Commande disponible (dans SIGEP): php artisan sigep:export-pigia"
echo "Exemple sortie personnalisée: php artisan sigep:export-pigia --path=storage/app/sigep_to_pigia.json"
