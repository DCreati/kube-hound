declare -A array1
array1["chiave1"]="valore1"
array1["chiave2"]="valore2"

declare -A array2
array2["chiave2"]="valore2"
array2["chiave3"]="valore3"
array2["chiave4"]="valore4"

declare -A array_combinato

for chiave in "${!array1[@]}"; do
  valore="${array1[$chiave]}"
  array_combinato["$chiave"]="$valore"
done

for chiave in "${!array2[@]}"; do
  valore="${array2[$chiave]}"
  array_combinato["$chiave"]="$valore"
done

for chiave in "${!array_combinato[@]}"; do
    echo "${array_combinato["$chiave"]}"
done