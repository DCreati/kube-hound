declare -A array1
array1["chiave1"]="valore1"
array1["chiave2"]="valore2"

declare -A array2
array2["chiave2"]="valore2"
array2["chiave3"]="valore3"
array2["chiave4"]="valore4"

declare -A array_combinato

services=""
already=()
for analisys_key in "${array1[@]}" "${array2[@]}"; do
    echo $analisys_key
done