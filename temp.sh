#!/bin/bash

# Array per analisi statiche e dinamiche
declare -a static_services=()
declare -a dynamic_services=()
declare -A all_services=()

# Parsing del docker-compose in stringa
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|,$s\]$s\$|]|" \
        -e ":1;s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1\2: [\3]\n\1  - \4|;t1" \
        -e "s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s\]|\1\2:\n\1  - \3|;p" $1 | \
   sed -ne "s|,$s}$s\$|}|" \
        -e ":1;s|^\($s\)-$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1- {\2}\n\1  \3: \4|;t1" \
        -e    "s|^\($s\)-$s{$s\(.*\)$s}|\1-\n\1  \2|;p" | \
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)-$s[\"']\(.*\)[\"']$s\$|\1$fs$fs\2|p" \
        -e "s|^\($s\)-$s\(.*\)$s\$|\1$fs$fs\2|p" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" | \
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      
      for (i in vname) {
         if (i > indent) {
            delete vname[i]; idx[i]=0
         }
      }
      
      if(length($2)== 0){
         vname[indent]= ++idx[indent] 
      };
      
      if (length($3) > 0) {
         vn=""; 
         for (i=0; i<indent; i++) { 
            vn=(vn)(vname[i])("_")
         }
         printf("%s%s%s=\"%s\"\n", "'$prefix'", vn, vname[indent], $3);
      }
   }'
}

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
      env_vars+=("$value") # add value
    fi
  done

  echo "${env_vars[@]}"
}

# Classifica il servizio in dinamico o statico
function add_service  {
    if [[ "$1" =~ ^[Ss][Tt][Aa][Tt][Ii][Cc]$ ]]; then
      static_services+=("$2")
    elif [[ "$1" =~ ^[Dd][Yy][Nn][Aa][Mm][Ii][Cc]$ ]]; then
      dynamic_services+=("$2")
    fi
}


## - 1 Esecuzione del parsing, conversione in array e rimozione valori inutili
eval $(parse_yaml docker-compose.yml)
services_string=$(parse_yaml docker-compose.yml)

# Creazione array riga stringa -> elemento
mapfile -t services_array <<< "$services_string"

filtered_services_array=()
for item in "${services_array[@]}"; do # prendiamo tutti i services, il resto non ci interessa
    if [[ "$item" == services* ]]; then # Verifichiamo se la stringa inizia con "services"
        filtered_services_array+=("$item")
    fi
done

services_array=("${filtered_services_array[@]}")


## - 2 Trova i container nel docker-compose (usiamo yq) ##
if ! command -v yq >/dev/null 2>&1 || ! type yq >/dev/null 2>&1 || ! hash yq 2>/dev/null; then
  echo "yq is required to continue:"
  sudo snap install yq
fi

mapfile -t services < <(yq eval '.services | keys | .[]' docker-compose.yml 2>/dev/null) # Prende i nomi dei container

## - 3 Scansione di ciascun servizio e classificazione ##
for service in "${services[@]}"; do
  all_services+=("$service")
  env_vars=($(extract_environment_vars "$service"))

  if [[ ${#env_vars[@]} -eq 0 ]]; then
    echo "No environment variables found for the service $service."
  else
    for var in "${env_vars[@]}"; do
      var=$(echo "$var" | tr -d '"') # rimuove gli apici
      values=$(echo "$var" | cut -d '=' -f 2) # Contiene il tipo dell'analisi
      if [[ "$var" =~ ^TYPE=[a-zA-Z,]*$ ]]; then # Controlla che la variabile d'ambiente sia quella desiderata
        IFS=',' read -r -a type_services <<< "$values"
        for type in "${type_services[@]}"; do
          add_service "$type" "$service"
        done
      elif [[ "$var" =~ ^ANALISYS=[a-zA-Z,]*$ ]]; then
        IFS=',' read -r -a analisys_id <<< "$values"
        for id in "${analisys_id[@]}"; do
          all_services["$id"]="$service"
        done
      fi
    done
  fi
done

## - 4 (Main) Esecuzione del compose ##
statement_count=0
statement="ARGS=\"$@\" docker compose up"
while getopts sdl: opt; do
    case "$opt" in
        l|d|s) 
            if [[ $statement_count -eq 1 ]]; then
                exit 1
            fi
            statement_count=$((count + 1))

            if [[ $opt == "s" ]]; then
                for single in "${static_services[@]}"; do
                  statement="$statement $single"
                done
            elif [[ $opt == "d" ]]; then
                for single in "${dynamic_services[@]}"; do
                  statement="$statement $single"
                done
            elif [[ $opt == "l" ]]; then 
                IFS=',' read -r -a analisys_list <<< "$OPTARG"
                for analisys in "${analisys_list[@]}"; do
                  statement="$statement"
                done
            fi

            statement="$statement app"
            ;;

        ?)
          echo "niente"
          ;;
          # eval "$statement"
    esac
done

echo "$statement"