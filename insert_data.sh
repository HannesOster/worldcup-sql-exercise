#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Insert teams (avoid duplicates using ON CONFLICT)
while IFS=',' read -r year round winner opponent winner_goals opponent_goals
do
  # Skip header
  if [[ $year != "year" ]]
  then
    # Insert winner
    $PSQL "INSERT INTO teams(name) VALUES('$winner') ON CONFLICT(name) DO NOTHING;"
    # Insert opponent
    $PSQL "INSERT INTO teams(name) VALUES('$opponent') ON CONFLICT(name) DO NOTHING;"

    # Get team_ids
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")

    # Insert game
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals);"
  fi
done < games.csv

echo "Data inserted successfully!"
