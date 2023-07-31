#!/bin/bash

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

# Array originale
example_array=("app" "app_build" "kubesec_io" "kubesec_io_command" "kubesec_io_environment" "kubesec_io_ports")

# Array risultante con elementi senza sottostringhe
result_array=()
for element in "${example_array[@]}"; do
  sub_result="$(is_substring "$element" "${example_array[@]}")"
  if $sub_result; then
    result_array+=("$element")
  fi
done

# Stampa gli elementi dell'array risultante
echo "Elementi dell'array risultante:"
for element in "${result_array[@]}"; do
  echo "$element"
done
