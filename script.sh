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
    local return_code=$?

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
    strace -o stracebw.log -e trace=file,read,write,openat gimp -i -b "$gimp_batch_commands" &> /dev/null

    echo "Se scriu semnalele trimise si primite de aplicatie in sig.log..."
    strace -o sigbw.log -e trace=signal gimp -i -b "$gimp_batch_commands" &> /dev/null &

    echo "Se scriu apelurile de biblioteci in ltrace.log..."
    ltrace -o ltracebw.log -e '*' gimp -i -b "(let* (
      (image (car (gimp-file-load RUN-NONINTERACTIVE \"$PWD/$input_file\" \"$PWD/$input_file\")))
      (drawable (car (gimp-image-get-active-layer image))))
     (gimp-drawable-desaturate drawable 0)
     (gimp-file-save RUN-NONINTERACTIVE image drawable \"$PWD/$output_file\" \"$PWD/$output_file\")
     (gimp-quit 0))" &> /dev/null

    created_files=$(grep -oP 'openat\(([^,]+), "[^"]+", O_WRONLY\|O_CREAT\|O_EXCL.*' stracebw.log | awk -F ', ' '{print $2}')
    echo "Fisiere create sau modificate: $created_files"

    echo "Operatie finalizata!"
    echo "Codul de return al aplicatiei: $return_code"
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
    local return_code=$?

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
    strace -o stracers.log -e trace=file,read,write,openat gimp -i -b "$gimp_batch_commands" &> /dev/null

    echo "Se scriu semnalele trimise si primite de aplicatie in sig.log..."
    strace -o sigrs.log -e trace=signal gimp -i -b "$gimp_batch_commands" &> /dev/null &

    echo "Se scriu apelurile de biblioteci in ltrace.log..."
    ltrace -o ltracers.log -e '*' gimp -i -b "(let* (
      (image (car (gimp-file-load RUN-NONINTERACTIVE \"$PWD/$input_file\" \"$PWD/$input_file\")))
      (drawable (car (gimp-image-get-active-layer image))))
     (gimp-image-scale image "$dim1" "$dim2")
     (gimp-file-save RUN-NONINTERACTIVE image drawable \"$PWD/$output_file\" \"$PWD/$output_file\")
     (gimp-quit 0))" &> /dev/null

    created_files=$(grep -oP 'openat\(([^,]+), "[^"]+", O_WRONLY\|O_CREAT\|O_EXCL.*' stracebw.log | awk -F ', ' '{print $2}')
    echo "Fisiere create sau modificate: $created_files"

    echo "Operatie finalizata!"
    echo "Codul de return al aplicatiei: $return_code"
}


rotate() {
    local input_file="$1"
    local output_file="$2"
    local dir="$3"

    start_time=$(date +%s.%N)

    #set -x

    # Rotirea imaginii
    gimp_batch_commands="(let* (
      (pi 3.141592653589793)
      (image (car (gimp-file-load RUN-NONINTERACTIVE \"$PWD/$input_file\" \"$PWD/$input_file\")))
      (drawable (car (gimp-image-get-active-layer image))))
     (gimp-item-transform-rotate drawable (* "$dir" (/ pi 180.0)) TRUE (/ (car (gimp-drawable-width drawable)) 2) (/ (car (gimp-drawable-height drawable)) 2))
     (gimp-file-save RUN-NONINTERACTIVE image drawable \"$PWD/$output_file\" \"$PWD/$output_file\")
     (gimp-quit 0))"

    gimp -i -b "$gimp_batch_commands" &> /dev/null
    msg="$?"

    end_time=$(date +%s.%N)
    execution_time=$(echo "$end_time - $start_time" | bc)
    echo "Timpul total de executie: $execution_time secunde"

    if [ $msg -eq 0 ]
    then
        echo "Imaginea a fost rotita"
    else
        echo "Imaginea nu a putut fi rotita"
    fi

    echo "Se scriu apelurile de sistem în strace.log..."
    strace -o stracerot.log -e trace=file,read,write,openat gimp -i -b "$gimp_batch_commands" &> /dev/null

    echo "Se scriu semnalele trimise si primite de aplicatie in sig.log..."
    strace -o sigrot.log -e trace=signal gimp -i -b "$gimp_batch_commands" &> /dev/null &

    echo "Se scriu apelurile de biblioteci în ltrace.log..."
    ltrace -o ltracerot.log -e '*' gimp -i -b "(let* (
      (pi 3.141592653589793)
      (image (car (gimp-file-load RUN-NONINTERACTIVE \"$PWD/$input_file\" \"$PWD/$input_file\")))
      (drawable (car (gimp-image-get-active-layer image))))
     (gimp-item-transform-rotate drawable (* "$dir" (/ pi 180.0)) TRUE (/ (car (gimp-drawable-width drawable)) 2) (/ (car (gimp-drawable-height drawable)) 2))
     (gimp-file-save RUN-NONINTERACTIVE image drawable \"$PWD/$output_file\" \"$PWD/$output_file\")
     (gimp-quit 0))" &> /dev/null
    created_files=$(grep -oP 'openat\(([^,]+), "[^"]+", O_WRONLY\|O_CREAT\|O_EXCL.*' stracebw.log | awk -F ', ' '{print $2}')
    echo "Fisiere create sau modificate: $created_files"

    echo "Operatie finalizata!"
    echo "Codul de return al aplicatiei: $msg"
}

add_text(){

    local input_file="$1"
    local output_file="$2"
    local text="$3"

    start_time=$(date +%s.%N)

    gimp_batch_commands="(let* (
      (image (car (gimp-file-load RUN-NONINTERACTIVE \"$PWD/$input_file\" \"$PWD/$input_file\")))
      (drawable (car (gimp-image-get-active-layer image))))
     (gimp-text-fontname image drawable 5 5 \"$text\" 20 TRUE 1000 PIXELS \"Arial\")
     (gimp-file-save RUN-NONINTERACTIVE image drawable \"$PWD/$output_file\" \"$PWD/$output_file\")
     (gimp-quit 0))"

    gimp -i -b "$gimp_batch_commands" &> /dev/null
    local return_code=$?

    end_time=$(date +%s.%N)
    execution_time=$(echo "$end_time - $start_time" | bc)
    echo "Timpul total de executie: $execution_time secunde"

    echo "Se scriu apelurile de sistem în strace.log..."
    strace -o stracetxt.log -e trace=file,read,write,openat gimp -i -b "$gimp_batch_commands" &> /dev/null

    echo "Se scriu semnalele trimise si primite de aplicatie in sig.log..."
    strace -o sigtxt.log -e trace=signal gimp -i -b "$gimp_batch_commands" &> /dev/null &

    echo "Se scriu apelurile de biblioteci în ltrace.log..."
    ltrace -o ltracetxt.log -e '*' gimp -i -b "(let* (
      (image (car (gimp-file-load RUN-NONINTERACTIVE \"$PWD/$input_file\" \"$PWD/$input_file\")))
      (drawable (car (gimp-image-get-active-layer image))))
     (gimp-text-fontname image drawable 5 5 \"$text\" 20 TRUE 1000 PIXELS \"Arial\")
     (gimp-file-save RUN-NONINTERACTIVE image drawable \"$PWD/$output_file\" \"$PWD/$output_file\")
     (gimp-quit 0))" &> /dev/null
    created_files=$(grep -oP 'openat\(([^,]+), "[^"]+", O_WRONLY\|O_CREAT\|O_EXCL.*' stracebw.log | awk -F ', ' '{print $2}')
    echo "Fisiere create sau modificate: $created_files"

    echo "Operatie finalizata!"
    echo "Codul de return al aplicatiei: $return_code"
}

case $1 in
    "1")
        input_file="$2"
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
        output_file="$3"
        bwfilter "$input_file" "$output_file"
    ;;

    "2")
        input_file="$2"
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

        dim1="$4"
        if  [[ ! "$dim1" =~ ^[0-9]+$ ]]
            then
                echo "Dimensiunea introdusa trebuie sa fie un numar"
                exit 1
            fi

        dim2="$5"
        if  [[ ! "$dim2" =~ ^[0-9]+$ ]]
            then
                echo "Dimensiunea introdusa trebuie sa fie un numar"
                exit 1
            fi

        output_file="$3"
        resize "$input_file" "$output_file" "$dim1" "$dim2"
    ;;

    "3")
        input_file="$2"
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
        dir="$4"
        grad="$5"
        if [ "$dir" = "stanga" ]
        then
            rot="-$grad"
        elif [ "$dir" = "dreapta" ]
        then
            rot="$grad"
        else
            echo "Nu ati introdus o directie valida"
            exit 1
        fi
        output_file="$3"
        rotate "$input_file" "$output_file" "$rot"
    ;;

    "4")
        input_file="$2"
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
        text="$3"
        output_file="output_text.png"
        add_text "$input_file" "$output_file" "$text"
    ;;

    *)
        echo "Optiune invalida. Utilizare: $0 {1|2|3|4} [arguments...]"
        exit 1
    ;;
esac
