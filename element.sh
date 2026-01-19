#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"


if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

INPUT=$1


if [[ $INPUT =~ ^[0-9]+$ ]]
then
  ELEMENT_CONDITION="atomic_number=$INPUT"
else
  
  if [[ $INPUT =~ ^[A-Za-z]{1,2}$ ]]
  then
    ELEMENT_CONDITION="symbol='$INPUT'"
  else
    
    ELEMENT_CONDITION="name='$INPUT'"
  fi
fi


RESULT=$($PSQL "
  SELECT e.atomic_number, e.name, e.symbol, p.type, p.atomic_mass, 
         p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p USING(atomic_number)
  WHERE $ELEMENT_CONDITION;
")


if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
  exit
fi


IFS='|' read ATOMIC_NUM NAME SYMBOL TYPE MASS MELT BOIL <<< "$RESULT"

echo "The element with atomic number $ATOMIC_NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
