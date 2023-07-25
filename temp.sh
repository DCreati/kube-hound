#!/bin/bash

file_path="docker-compose.yml"  # Sostituisci "nome_file.txt" con il percorso del tuo file

# Controlla se il file esiste
if [ ! -f "$file_path" ]; then
  echo "Il file $file_path non esiste."
  exit 1
fi

# Leggi il file riga per riga
while IFS= read -r line; do
  # Fai qualcosa con la riga (ad esempio, stampala)
  echo "linea: $line"
done < "$file_path"
