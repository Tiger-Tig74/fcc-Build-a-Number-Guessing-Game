#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# get user data from the database
get_user_data() {
  local username="$1"
  $PSQL "SELECT games_played, best_game FROM users WHERE username='$username';"
}

# update user data in the database
update_user_data() {
  local username="$1"
  local games_played="$2"
  local best_game="$3"
  $PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$username', $games_played, $best_game)
         ON CONFLICT (username) DO UPDATE SET games_played = EXCLUDED.games_played, best_game = EXCLUDED.best_game;" > /dev/null
}

# get username input
echo -n "Enter your username: "
read username

# Ensure username is not longer than 22 characters
username=${username:0:22}

# fetch user data
user_data=$(get_user_data "$username")
IFS='|' read -r games_played best_game <<< "$user_data"

# initialize games_played and best_game if not found
if [ -z "$games_played" ]; then
  games_played=0
  best_game=0
  echo "Welcome, $username! It looks like this is your first time here."
else
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

# game initialized
games_played=$((games_played + 1))

secret_number=$((RANDOM % 1000 + 1))

number_of_guesses=0

# main game logic
while true; do
  echo -n "Guess the secret number between 1 and 1000: "
  read guess

  if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  guess=$((guess))
  number_of_guesses=$((number_of_guesses + 1))

  if [ "$guess" -lt "$secret_number" ]; then
    echo "It's higher than that, guess again:"
  elif [ "$guess" -gt "$secret_number" ]; then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $number_of_guesses tries. The secret number was $secret_number. Nice job!"
    break
  fi
done

# update best game if necessary
if [ "$best_game" -eq 0 ] || [ "$number_of_guesses" -lt "$best_game" ]; then
  best_game=$number_of_guesses
fi

# update user data
update_user_data "$username" "$games_played" "$best_game"
