#!/bin/bash

path=$(dirname $0)
word=$(shuf -n 1 $path/wordle_La.txt)
console="\033[38;2;66;255;255mGuess the word:\033[0m\n"
echo -e "$console"

for i in {1..6}; do
    marked1=false
    marked2=false
    marked3=false
    marked4=false
    marked5=false

    while true; do
        read -N 5 draft

        if [[ $draft =~ [^a-zA-Z] ]]; then
            echo -e "\033[38;2;240;0;0m Wrong input\033[0m"
            read -n 1 -srp 'Press any key to continue'
            clear
            echo -e "$console"
            continue
        fi

        if (grep -Fxq "$draft" "$path"/wordle.txt); then
            console+="\n$draft"
            break
        else
            echo -e "\033[38;2;240;0;0m Not in word list\033[0m"
            read -n 1 -srp 'Press any key to continue'
            clear
            echo -e "$console"
        fi
    done

    for a in {1..5}; do
        pos=slot$a
        slot=marked$a
        if [[ $(echo $draft | cut -c$a) == $(echo $word | cut -c$a) ]]; then
            temp="\033[38;2;0;255;0m$(echo $draft | cut -c$a)\033[0m"
            eval "$pos"='$temp'
            temp=true
            eval "$slot"='$temp'
            greens+="$(echo $draft | cut -c$a)"
        fi
    done

    for a in {1..5}; do
        pos=slot$a
        for j in {1..5}; do
            slot=marked$j
            if [[ ${!pos} == "" && ${word:j-1:1} == ${draft:a-1:1} && ${!slot} == false ]]; then
                temp="\033[38;2;255;255;0m$(echo $draft | cut -c$a)\033[0m"
                eval "$pos"='$temp'
                temp=true
                eval "$slot"='$temp'
                yellows+="$(echo $draft | cut -c$a)"
                has_yellow=true
                break
            fi
        done
        if [[ $has_yellow == true ]]; then
            has_yellow=false
            continue
        fi
        if [[ ${!pos} == "" ]]; then
            temp="$(echo $draft | cut -c$a)"
            eval "$pos"='$temp'
            grays+="$(echo $draft | cut -c$a)"
        fi
    done

    output="$slot1$slot2$slot3$slot4$slot5"
    output_print="\n\n********** $output ********** \033[38;2;66;255;255mTry #$i\033[0m"

    echo -e "$output_print"

    if [[ ${#greens} == "5" ]]; then
        echo -e "Congrats! Correct word was found in \033[38;2;66;255;255m$i\033[0m attempts."
        exit
    fi

    greens="$(echo $greens | grep -o . | sort | tr -d "\n" | tr -s "a-z")"
    yellows="$(echo $yellows | grep -o . | sort | tr -d "\n" | tr -s "a-z")"
    grays="$(echo $grays | grep -o . | sort | tr -d "\n" | tr -s "a-z")"

    while read letter; do
        for j in $(seq 1 ${#greens}); do
            if [[ $letter == ${greens:j-1:1} ]]; then
                alphabet_print+="\033[38;2;0;255;0m$letter\033[0m"
                has_green=true
                break
            fi
        done
        if [[ $has_green == true ]]; then
            has_green=false
            continue
        fi
        for j in $(seq 1 ${#yellows}); do
            if [[ $letter == ${yellows:j-1:1} ]]; then
                alphabet_print+="\033[38;2;255;255;0m$letter\033[0m"
                has_yellow=true
                break
            fi
        done
        if [[ $has_yellow == true ]]; then
            has_yellow=false
            continue
        fi
        for j in $(seq 1 ${#grays}); do
            if [[ $letter == ${grays:j-1:1} ]]; then
                alphabet_print+="\033[38;2;240;0;0m$letter\033[0m"
                has_gray=true
                break
            fi
        done
        if [[ $has_gray == true ]]; then
            has_gray=false
            continue
        fi
        alphabet_print+="$letter"
    done <$path/alphabet.txt

    echo -e "$alphabet_print\n"

    console+="$output_print\n$alphabet_print\n"

    output=""
    alphabet_print=""
    greens=""
    slot1=""
    slot2=""
    slot3=""
    slot4=""
    slot5=""
done

echo -e "You lost! The correct word was: \033[38;2;66;255;255m$word\033[0m"

$SHELL
