#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

INPUT=$1

if [[ $INPUT =~ ^[0-9]+$ ]]; then
  ELEMENT_CONDITION="e.atomic_number=$INPUT"
elif [[ $INPUT =~ ^[A-Za-z]{1,2}$ ]]; then
  # Capitalize first letter for symbols
  INPUT="$(tr '[:lower:]' '[:upper:]' <<< "${INPUT:0:1}")${INPUT:1}"
  ELEMENT_CONDITION="e.symbol='$INPUT'"
else
  ELEMENT_CONDITION="e.name='$INPUT'"
fi

RESULT=$($PSQL "
  SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, 
         p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p USING(atomic_number)
  JOIN types t USING(type_id)
  WHERE $ELEMENT_CONDITION;
")



RESULT=$(echo $RESULT | xargs)

if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
  exit
fi

IFS='|' read ATOMIC_NUM NAME SYMBOL TYPE MASS MELT BOIL <<< "$RESULT"

echo "The element with atomic number $ATOMIC_NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
