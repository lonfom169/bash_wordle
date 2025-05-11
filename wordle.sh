#!/bin/bash

path=$(dirname $0)
word=$(shuf -n 1 $path/wordle_La.txt)
console="\033[38;2;66;255;255mGuess the word:\033[0m\n"
echo -e "$console"

for i in {1..6}; do
    while true; do
        read -N 5 draft

        if [[ $draft =~ [^a-zA-Z] ]]; then
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

        if (grep -Fxq "$draft" "$path"/wordle.txt); then
            console+="\n$draft"
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
    result=""
    slots=""
    alphabet_print=""

    for a in {1..5}; do
        if [[ $(echo $draft | cut -c$a) == $(echo $word | cut -c$a) ]]; then
            result+="\033[38;2;0;255;0m$(echo $draft | cut -c$a)\033[0m"
            greens+="$(echo $draft | cut -c$a)"
            slots+=$a
            continue
        fi
        for b in {1..5}; do
            if [[ $(echo $draft | cut -c$a) == $(echo $word | cut -c$b) && $(echo $b | tr -d "$slots") != "" ]]; then
                result+="\033[38;2;255;255;0m$(echo $draft | cut -c$a)\033[0m"
                yellows+="$(echo $draft | cut -c$a)"
                slots+=$b
                won=false
                gray=false
                break
            fi
        done
        if [[ $gray == true ]]; then
            result+="$(echo $draft | cut -c$a)"
            grays+="$(echo $draft | cut -c$a)"
            won=false
        else
            gray=true
        fi
    done

    output="\n********** $result ********** \033[38;2;66;255;255mTry #$i\033[0m"
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
    output=""
done

if [[ $won == false ]]; then
    echo -e "You lost! The correct word was: \033[38;2;66;255;255m$word\033[0m"
else
    echo -e "Congrats! Correct word was found in \033[38;2;66;255;255m$i\033[0m attempts."
fi

$SHELL
