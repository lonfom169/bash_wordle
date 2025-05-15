#!/bin/bash

path=$(dirname $0)
answer=$(shuf -n 1 $path/wordle_La.txt)
alphabet='abcdefghijklmnopqrstuvwxyz'
console="\033[38;2;66;255;255mGuess the word:\033[0m\n"

clear
echo -e "$console"

for i in {1..6}; do
    while true; do
        read -N 5 attempt

        if [[ $attempt =~ [^a-zA-Z] ]]; then
            echo -e "\033[38;2;240;0;0m Wrong input\033[0m"
            read -n 1 -srp 'Press any key to continue'
            clear
            if [[ $alphabet_print != "" ]]; then
                echo -e "$console$alphabet_print\n"
            else
                echo -e "$console"
            fi
            continue
        fi

        if (grep -Fxq "$attempt" "$path"/wordle.txt); then
            console+="\n$attempt"
            break
        else
            echo -e "\033[38;2;240;0;0m Not in word list\033[0m"
            read -n 1 -srp 'Press any key to continue'
            clear
            if [[ $alphabet_print != "" ]]; then
                echo -e "$console$alphabet_print\n"
            else
                echo -e "$console"
            fi
        fi
    done

    clear
    echo -e "$console"

    won=true
    gray=true
    green_slots=""
    slots=""

    for a in {1..5}; do
        char=$(echo $attempt | cut -c$a)
        if [[ $char == $(echo $answer | cut -c$a) ]]; then
            result[a]="\033[38;2;0;255;0m$char\033[0m"
            greens+=$char
            green_slots+=$a
        else
            won=false
        fi
    done

    for a in {1..5}; do
        if [[ $(echo $a | tr -d "$green_slots") == "" ]]; then
            continue
        fi
        char=$(echo $attempt | cut -c$a)
        for b in {1..5}; do
            if [[ $char == $(echo $answer | cut -c$b) && $(echo $b | tr -d "$slots$green_slots") != "" ]]; then
                result[a]="\033[38;2;255;255;0m$char\033[0m"
                yellows+=$char
                slots+=$b
                gray=false
                break
            fi
        done
        if [[ $gray == true && $(echo $a | tr -d "$green_slots") != "" ]]; then
            result[a]=$char
            grays+=$char
        else
            gray=true
        fi
    done

    output="\n********** $(echo ${result[*]} | tr -d [:space:]) ********** \033[38;2;66;255;255mTry #$i\033[0m"
    echo -e "$output"

    alphabet_print=""

    for a in {0..25}; do
        if [[ $(echo ${alphabet:a:1} | tr -d "$greens") == "" ]]; then
            alphabet_print+="\033[38;2;0;255;0m${alphabet:a:1}\033[0m"
        elif [[ $(echo ${alphabet:a:1} | tr -d "$yellows") == "" ]]; then
            alphabet_print+="\033[38;2;255;255;0m${alphabet:a:1}\033[0m"
        elif [[ $(echo ${alphabet:a:1} | tr -d "$grays") == "" ]]; then
            alphabet_print+="\033[38;2;240;0;0m${alphabet:a:1}\033[0m"
        else
            alphabet_print+=${alphabet:a:1}
        fi
    done

    echo -e "$alphabet_print\n"

    if [[ $won == true ]]; then
        echo -e "Congrats! Correct word was found in \033[38;2;66;255;255m$i\033[0m attempts."
        exec $SHELL
    fi

    console+="\n$output\n"
done

echo -e "You lost! The correct word was: \033[38;2;66;255;255m$answer\033[0m"
$SHELL
