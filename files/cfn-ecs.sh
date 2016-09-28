#!/bin/bash
set -e

# Exit gracefully if CLUSTER_NAME is not defined
if [[ -z $CLUSTER_NAME ]]
  then
  echo "Skipping ECS agent check as CLUSTER_NAME variable is not defined"
  exit 0
fi

# Start ECS agent
sudo start ecs

# Loop until ECS agent has registered to ECS cluster
echo "Checking ECS agent is joined to $CLUSTER_NAME"
until [[ "$(curl --fail --silent http://localhost:51678/v1/metadata | jq '.Cluster // empty' -r -e)" == $CLUSTER_NAME ]]
  do printf '.'
  sleep 5
done
echo "ECS agent successfully joined to $CLUSTER_NAME"

# Pause if PAUSE_TIME is defined
if [[ -n $PAUSE_TIME ]]
  then
  echo "Pausing for $PAUSE_TIME seconds..."
  sleep $PAUSE_TIME
fi


