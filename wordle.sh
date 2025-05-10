#!/bin/bash

path=$(dirname $0)
word=$(shuf -n 1 $path/wordle_La.txt)
console="\033[38;2;66;255;255mGuess the word:\033[0m\n"
echo -e "$console"

for i in {1..6}; do
    won=true

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
            echo -e "$console$alphabet_console\n"
            continue
        fi

        if (grep -Fxq "$draft" "$path"/wordle.txt); then
            console+="\n$draft"
            break
        else
            echo -e "\033[38;2;240;0;0m Not in word list\033[0m"
            read -n 1 -srp 'Press any key to continue'
            clear
            echo -e "$console$alphabet_console\n"
        fi
    done

    clear
    echo -e "$console"

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
                won=false
                break
            fi
        done
        if [[ ${!pos} == "" ]]; then
            temp="$(echo $draft | cut -c$a)"
            eval "$pos"='$temp'
            grays+="$(echo $draft | cut -c$a)"
            won=false
        fi
    done

    output="\n********** $slot1$slot2$slot3$slot4$slot5 ********** \033[38;2;66;255;255mTry #$i\033[0m"
    echo -e "$output"

    while read letter; do
        if [[ $(echo $letter | tr -d "$greens") == "" ]]; then
            alphabet_print+="\033[38;2;0;255;0m$letter\033[0m"
        elif [[ $(echo $letter | tr -d "$yellows") == "" ]]; then
            alphabet_print+="\033[38;2;255;255;0m$letter\033[0m"
        elif [[ $(echo $letter | tr -d "$grays") == "" ]]; then
            alphabet_print+="\033[38;2;240;0;0m$letter\033[0m"
        else
            alphabet_print+="$letter"
        fi
    done <$path/alphabet.txt

    echo -e "$alphabet_print\n"

    if [[ $won == true ]]; then
        break
    fi

    console+="\n$output\n"
    alphabet_console=$alphabet_print

    output=""
    alphabet_print=""
    slot1=""
    slot2=""
    slot3=""
    slot4=""
    slot5=""
done

if [[ $won == false ]]; then
    echo -e "You lost! The correct word was: \033[38;2;66;255;255m$word\033[0m"
else
    echo -e "Congrats! Correct word was found in \033[38;2;66;255;255m$i\033[0m attempts."
fi

$SHELL
