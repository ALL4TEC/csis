#!/bin/bash

if [ $1 = "master" ]
then
  echo ""
elif [ $1 = "develop" ]
then
  echo "-alpha"
else
  echo "-feat"
fi
