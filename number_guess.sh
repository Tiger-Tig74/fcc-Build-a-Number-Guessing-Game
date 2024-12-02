#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]; then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  # Existing user
  IFS="|" read USERNAME GAMES_PLAYED BEST_GAME <<<"$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0

while true; do
  read GUESS

  # Validation
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((NUMBER_OF_GUESSES++))

  if (( GUESS == SECRET_NUMBER )); then
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    # Update user stats
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
    NEW_BEST_GAME=$([[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]] && echo $NUMBER_OF_GUESSES || echo $BEST_GAME)
    UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1, best_game = $NEW_BEST_GAME WHERE username='$USERNAME'")

    break
  elif (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
done