#!/bin/bash

if ! command -v gimp &> /dev/null
then
    echo "GIMP nu este instalat. Instalează-l înainte de a rula acest script."
    exit 1
fi


if ! command -v strace &> /dev/null
then
    echo "strace nu este instalat. Instalează-l înainte de a rula acest script."
    exit 1
fi


if ! command -v ltrace &> /dev/null
then
    echo "ltrace nu este instalat. Instalează-l înainte de a rula acest script."
    exit 1
fi

input_file="mojito.png"
output_file="output_image.png"

if [ ! -f "$input_file" ]; then
    echo "Fișierul de intrare $input_file nu există."
    exit 1
fi

start_time=$(date +%s.%N)

# aplicarea unui filtru alb-negru
gimp_batch_commands="(let* (
  (image (car (gimp-file-load RUN-NONINTERACTIVE \"$PWD/$input_file\" \"$PWD/$input_file\")))
  (drawable (car (gimp-image-get-active-layer image))))
 (gimp-drawable-desaturate drawable 0)
 (gimp-file-save RUN-NONINTERACTIVE image drawable \"$PWD/$output_file\" \"$PWD/$output_file\")
 (gimp-quit 0))"

gimp -i -b "$gimp_batch_commands"

end_time=$(date +%s.%N)
execution_time=$(echo "$end_time - $start_time" | bc)
echo "Timpul total de execuție: $execution_time secunde"

