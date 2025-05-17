#!/bin/bash

path=$(dirname $0)
answer=$(shuf -n 1 $path/wordle_La.txt)
alphabet='abcdefghijklmnopqrstuvwxyz'
console='\033[38;2;66;255;255mGuess the word:\033[0m\n'
arg1='@@@@@'

clear
echo -e $console

for i in {1..6}; do
    while true; do
        read -N 5 attempt

        if (grep -Fxq $attempt $path/wordle.txt); then
            console+="\n$attempt"
            break
        else
            if [[ $attempt =~ [^a-zA-Z] ]]; then
                echo -e '\033[38;2;240;0;0m Wrong input\033[0m'
            else
                echo -e '\033[38;2;240;0;0m Not in word list\033[0m'
            fi

            read -n 1 -srp 'Press any key to continue'
            clear

            if [[ $alphabet_print != '' ]]; then
                echo -e "$console$alphabet_print\n"
            else
                echo -e $console
            fi

            continue
        fi
    done

    clear
    echo -e "$console"

    won=true
    gray=true
    green_slots=''
    slots=''
    greens=''
    yellows=''

    for a in {0..4}; do
        char=${attempt:a:1}

        if [ $char == ${answer:a:1} ]; then
            result[a]="\033[38;2;0;255;0m$char\033[0m"
            greens+=$char
            green_slots+=$a
            arg1=$(echo $arg1 | sed s/./$char/$((a+1)))
        else
            won=false
        fi
    done

    for a in {0..4}; do
        if [[ $green_slots =~ $a ]]; then
            continue
        fi

        char=${attempt:a:1}

        for b in {0..4}; do
            if [[ $char == ${answer:b:1} && ! $slots$green_slots =~ $b ]]; then
                result[a]="\033[38;2;255;255;0m$char\033[0m"
                yellows+=$char
                slots+=$b
                gray=false
                arg4+=$char$a
                break
            fi
        done

        if [[ $gray == true && ! $green_slots =~ $a ]]; then
            result[a]=$char
            grays+=$char

            if [[ $greens$yellows =~ $char ]]; then
                if [[ ! $arg5 =~ $char ]]; then
                    arg5+=$char$(echo $greens$yellows | grep -o $char | wc -l)
                fi

                grays=$(echo $grays | tr -d $char)
            fi
        else
            gray=true
        fi
    done

    not_gray=$greens$yellows

    until [[ $not_gray == '' ]]; do
        count=$(echo $not_gray | grep -o ${not_gray:0:1} | wc -l)

        if [[ $arg2 =~ ${not_gray:0:1} ]]; then
            if [ $count > $(echo $arg2 | cut -d ${not_gray:0:1} -f2 | cut -c1) ]; then
                arg2=${arg2/${not_gray:0:1}?/${not_gray:0:1}$count}
            fi
        else
            arg2+=${not_gray:0:1}$count
        fi

        not_gray=$(echo $not_gray | tr -d ${not_gray:0:1})
    done

    output="\n********** $(echo ${result[*]} | tr -d [:space:]) ********** \033[38;2;66;255;255mTry #$i\033[0m"

    if [ $won == false ]; then
        output+=" -> $($path/evaluator - $arg1 - $arg2 - $grays - $arg4 - $arg5)"
    fi

    echo -e "$output"

    alphabet_print=''
    all_greens+=$greens
    all_yellows+=$yellows

    for a in {0..25}; do
        if [[ $all_greens =~ ${alphabet:a:1} ]]; then
            alphabet_print+="\033[38;2;0;255;0m${alphabet:a:1}\033[0m"
        elif [[ $all_yellows =~ ${alphabet:a:1} ]]; then
            alphabet_print+="\033[38;2;255;255;0m${alphabet:a:1}\033[0m"
        elif [[ $grays =~ ${alphabet:a:1} ]]; then
            alphabet_print+="\033[38;2;240;0;0m${alphabet:a:1}\033[0m"
        else
            alphabet_print+=${alphabet:a:1}
        fi
    done

    echo -e "$alphabet_print\n"

    if [ $won == true ]; then
        echo -e "Congrats! Correct word was found in \033[38;2;66;255;255m$i\033[0m attempts."
        exec $SHELL
    fi

    console+="\n$output\n"
done

echo -e "You lost! The correct word was: \033[38;2;66;255;255m$answer\033[0m"
$SHELL
