#!/bin/bash

if ! command -v gimp &> /dev/null
then
    echo "GIMP nu este instalat."
    exit 1
fi

if ! command -v strace &> /dev/null
then
    echo "strace nu este instalat."
    exit 1
fi

if ! command -v ltrace &> /dev/null
then
    echo "ltrace nu este instalat."
    exit 1
fi

bwfilter() {
    local input_file="$1"
    local output_file="$2"

    start_time=$(date +%s.%N)

    # aplicarea unui filtru alb-negru
    gimp_batch_commands="(let* (
      (image (car (gimp-file-load RUN-NONINTERACTIVE \"$PWD/$input_file\" \"$PWD/$input_file\")))
      (drawable (car (gimp-image-get-active-layer image))))
     (gimp-drawable-desaturate drawable 0)
     (gimp-file-save RUN-NONINTERACTIVE image drawable \"$PWD/$output_file\" \"$PWD/$output_file\")
     (gimp-quit 0))"

    gimp -i -b "$gimp_batch_commands" &> /dev/null

    end_time=$(date +%s.%N)
    execution_time=$(echo "$end_time - $start_time" | bc)
    echo "Timpul total de executie: $execution_time secunde"

    identify_output=$(identify -verbose "$output_file")

    if echo "$identify_output" | grep -i "Type: Grayscale" &> /dev/null
    then
        echo "Imaginea este alb-negru."
    else
        echo "Imaginea nu este alb-negru."
    fi

    echo "Se scriu apelurile de sistem in strace.log..."
    strace -o stracebw.log -e trace=file,read,write gimp -i -b "$gimp_batch_commands" &> /dev/null

    echo "Se scriu apelurile de biblioteci in ltrace.log..."
    ltrace -o ltracebw.log gimp -i -b "$gimp_batch_commands" &> /dev/null

    echo "Operatie finalizata!"
}

resize() {
    local input_file="$1"
    local output_file="$2"
    local dim1="$3"
    local dim2="$4"

    start_time=$(date +%s.%N)

    # Redimensionarea imaginii
    gimp_batch_commands="(let* (
      (image (car (gimp-file-load RUN-NONINTERACTIVE \"$PWD/$input_file\" \"$PWD/$input_file\")))
      (drawable (car (gimp-image-get-active-layer image))))
     (gimp-image-scale image "$dim1" "$dim2")
     (gimp-file-save RUN-NONINTERACTIVE image drawable \"$PWD/$output_file\" \"$PWD/$output_file\")
     (gimp-quit 0))"

    gimp -i -b "$gimp_batch_commands" &> /dev/null

    end_time=$(date +%s.%N)
    execution_time=$(echo "$end_time - $start_time" | bc)
    echo "Timpul total de executie: $execution_time secunde"

    dimensions=$(identify -format "%wx%h" "$output_file")
    if [ "$dimensions" = "${dim1}x${dim2}" ]
    then
        echo "Dimensiunile au fost modificate"
    else
        echo "Dimensiunile nu au putut fi modificate"
    fi

    echo "Se scriu apelurile de sistem in strace.log..."
    strace -o stracers.log -e trace=file,read,write gimp -i -b "$gimp_batch_commands" &> /dev/null

    echo "Se scriu apelurile de biblioteci in ltrace.log..."
    ltrace -o ltracers.log gimp -i -b "$gimp_batch_commands" &> /dev/null

    echo "Operatie finalizata!"
}


rotate() {
    local input_file="$1"
    local output_file="$2"
    local dir="$3"

    start_time=$(date +%s.%N)

    # Rotirea imaginii
   
}


PS3="Alegeti dintre optiunile de mai jos:"
select ITEM in "Aplicare filtru black and white" "Redimensionarea imaginii" "Rotirea imaginii" "Exit"
do
	case $REPLY in
		1) echo "Introduceti numele fisierului pe care doriti sa il modificati: "
            read input_file
            if [ ! -f "$input_file" ]
            then
                echo "Fisierul de intrare $input_file nu exista."
                exit 1
            fi

            file_output=$(file -b --mime-type "$input_file" | egrep -i "image")
            if [[ ! -n "$file_output" ]]
            then
                echo "Fisierul furnizat nu e o imagine"
                exit 1
            fi

            output_file="output_bw.png"
            bwfilter "$input_file" "$output_file"
		;;

        2) echo "Introduceti numele fisierului pe care doriti sa il modificati: "
            read input_file 
            if [ ! -f "$input_file" ]
            then
                echo "Fisierul de intrare $input_file nu exista."
                exit 1
            fi
            file_output=$(file -b --mime-type "$input_file" | egrep -i "image")
            if [[ ! -n "$file_output" ]]
            then
                echo "Fisierul furnizat nu e o imagine"
                exit 1
            fi
           echo "Introduceti latimea: "
            read dim1
            if  [[ ! "$dim1" =~ ^[0-9]+$ ]]
            then
                echo "Dimensiunea introdusa trebuie sa fie un numar"
                exit 1
            fi
           echo "Introduceti lungimea: "

            read dim2
            if  [[ ! "$dim2" =~ ^[0-9]+$ ]]
            then
                echo "Dimensiunea introdusa trebuie sa fie un numar"
                exit 1
            fi

            output_file="output_resized.png"
            resize "$input_file" "$output_file" "$dim1" "$dim2"
        ;;

        3) echo "Introduceti numele fisierului pe care doriti sa il modificati: "
            read input_file
            if [ ! -f "$input_file" ]
            then
                echo "Fisierul de intrare $input_file nu exista."
                exit 1
            fi
            file_output=$(file -b --mime-type "$input_file" | egrep -i "image")
            if [[ ! -n "$file_output" ]]
            then
                echo "Fisierul furnizat nu e o imagine"
                exit 1
            fi

            echo "Introduceti directia de rotatie (stanga/dreapta): "
            read dir
            echo "Introduceti gradul de rotatie (1-180): "
            read grad
            if [ "$dir" = "stanga" ]
            then
                rot="-""$grad"
                output_file="output_rotated.png"
                rotate "$input_file" "$output_file" "$rot"
            elif [ "$dir" = "dreapta" ]
            then
                output_file="output_rotated.png"
                rotate "$input_file" "$output_file" "$grad"
            else
                echo "Nu ati introdus o directie valida"
                exit 1
            fi 
        ;;

		4) exit 0 ;;
		*) echo "Optiune inexistenta"
	esac
done

