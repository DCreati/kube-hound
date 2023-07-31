#!/bin/bash

# La stringa di parsing fornita
services_string='version="3"
services_app_build_context="."
services_app_build_dockerfile="Dockerfile"
services_app_command="poetry run python -m kube_hound ${ARGS}"
services_kubesec_io_image="kubesec/kubesec:v2"
services_kubesec_io_ports_1="8080:8080"
services_kubesec_io_command_1="http"
services_kubesec_io_command_2="8080"
services_kubesec_io_environment_1="TYPE=static,dynamic"'

# Creazione array riga stringa -> elemento
mapfile -t services_array <<< "$services_string"

filtered_services_array=()
for item in "${services_array[@]}"; do # prendiamo tutti i services, il resto non ci interessa
    if [[ "$item" == services* ]]; then # Verifichiamo se la stringa inizia con "services"
        filtered_services_array+=("$item")
    fi
done

services_array=("${filtered_services_array[@]}")


# Funzione per verificare se una stringa è una sottostringa di un altro elemento dell'array
function is_substring() {
  local str="$1"
  local response=false
  shift
  
  for element in "$@"; do
    if [[ "$element" != "$str" && "$element" == *"$str"* ]]; then
      response=true
    fi
  done
  
  # echo "$element - $str - $response"
  echo "$response"
}

# Funzione per estrarre le variabili dall'environment di un servizio
function extract_environment_vars() {
  local prefix="services_$1_environment_"
  declare -a env_vars

  for item in "${services_array[@]}"; do
    IFS='=' read -r key value <<< "$item"
    if [[ $key == "$prefix"* ]]; then
      env_vars+=("services_$1_environment_${key#$prefix}")
    fi
  done

  echo "${env_vars[@]}"
}


## - 1 Trova i container nel docker-compose (usiamo yq) ##
check_yq=$(yq --version 2>&1)

# Controlla se l'output contiene il messaggio di errore tipico di un comando inesistente o non installato
if ! command -v yq >/dev/null 2>&1 || ! type yq >/dev/null 2>&1 || ! hash yq 2>/dev/null; then
  echo "yq is required to continue:"
  sudo snap install yq
fi

mapfile -t services < <(yq eval '.services | keys | .[]' docker-compose.yml 2>/dev/null) # Prende i nomi dei container

## - 2 Scansione di ciascun servizio e stampa delle variabili dell'environment ##
for service in "${services[@]}"; do
  echo "Variabili di ambiente per il servizio $service:"
  env_vars=($(extract_environment_vars "$service"))

  if [[ ${#env_vars[@]} -eq 0 ]]; then
    echo "Nessuna variabile di ambiente trovata per il servizio $service."
  else
    for var in "${env_vars[@]}"; do
      echo "- $var"
    done
  fi

  echo
done