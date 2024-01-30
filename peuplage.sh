#!/bin/bash

#BAsic Rails Migration function
function migration {
  echo "-----------[rails db:migrate:reset]------" ;
  rails db:migrate:reset ;
  echo "-------------[rails db:seed]-------------" ;
  rails db:seed ;
  loading ;
  echo "--------------------[DONE]---------------"
}

function loading {
sleep 7 &
PID=$!
i=1
sp="/-\|"
echo -n ' '
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done
}

#Choose peuplage environement
echo "In which environement would you like to seed ? "
echo "[1] Development"
echo "[2] Production"
echo "[3] Test"
read reponse
if [[ $reponse == 1 ]]; then
  echo "--> SET : RAILS_ENV=development"
  export RAILS_ENV=development
elif [[ $reponse == 2 ]]; then
  echo "--> SET : RAILS_ENV=production"
  export RAILS_ENV=production
elif [[ $reponse == 3 ]]; then
  echo "--> SET : RAILS_ENV=test"
  export RAILS_ENV=test
else
  echo "******NOTHING TO DO***********"
  exit 1
fi
# Call migration function to seed
migration
