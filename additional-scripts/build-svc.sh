#!/bin/bash

docker build -t openjdk:jdk17-spring-petclinic  \
  -f dockerfile.svc .
