## Overview

bash_wordle is an implementation of the popular Wordle game, written in bash.
It is meant to be played completely offline, on Unix-like systems.

## Running the script

```
git clone https://github.com/lonfom169/bash_wordle
cd bash_wordle
gcc -O3 evaluator.c -o evaluator && strip evaluator
./wordle.sh
```

## How to play

Guess the right word (which will always contain 5 letters) within 6 attempts to
win the game. The green character indicates that the letter exists and is in the
correct spot, thus it will be marked as green in the alphabet representation.
The yellow character indicates that the letter exists but is in the wrong position.
Otherwise, the letter is incorrect regardless of its position and will be marked as
red in the alphabet representation.

The word will be tried as soon as the fifth character is typed. To cancel the current
attempt, just type invalid chars until it fails and press any key to proceed.
