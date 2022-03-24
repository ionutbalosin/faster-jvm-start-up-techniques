#!/bin/bash

if [ "--launch" == "$1" ]
then
  echo "WARNING: Using the 'launch' profile will only start application Docker container. This assumes there is an already built imagine."
  eval "docker-compose -f docker-compose.yml up -d --remove-orphans"
else
  echo "Using default profile will build, create and start the application Docker container."
  ./build-svc.sh
  eval "docker-compose -f docker-compose.yml up -d --remove-orphans"
fi
