#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME
USER_EXISTS=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
if [[ ! -z $USER_EXISTS ]]
then 
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
fi

echo Guess the secret number between 1 and 1000:
RAND_NUM=$(( 1 + $RANDOM % 1000 ))
NUM_GUESSES=0
while [[ $GUESS -ne $RAND_NUM ]];
do 
  read GUESS
  ((NUM_GUESSES++))
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS -gt $RAND_NUM ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS -lt $RAND_NUM ]]
    then
      echo "It's higher than that, guess again:"
    else
      echo You guessed it in $NUM_GUESSES tries. The secret number was $RAND_NUM. Nice job!
      BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
      UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE username='$USERNAME'")
      if [[ $NUM_GUESSES -lt $BEST_GAME || $BEST_GAME == 0 ]]
      then
        UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$NUM_GUESSES WHERE username='$USERNAME'")
      fi
    fi
  else
    echo That is not an integer, guess again:
fi
done

