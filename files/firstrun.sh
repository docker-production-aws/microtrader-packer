#!/bin/bash
set -e

# Write AWS Logs region
sudo tee /etc/awslogs/awscli.conf << EOF > /dev/null
[plugins]
cwlogs = cwlogs
[default]
region = ${AWS_DEFAULT_REGION}
EOF

# Write AWS Logs config
sudo tee /etc/awslogs/awslogs.conf << EOF > /dev/null
[general]
state_file = /var/lib/awslogs/agent-state    
 
[/var/log/dmesg]
file = /var/log/dmesg
log_group_name = ${STACK_NAME}/EC2/${AUTOSCALING_GROUP}/var/log/dmesg
log_stream_name = {instance_id}

[/var/log/messages]
file = /var/log/messages
log_group_name = ${STACK_NAME}/EC2/${AUTOSCALING_GROUP}/var/log/messages
log_stream_name = {instance_id}
datetime_format = %b %d %H:%M:%S

[/var/log/docker]
file = /var/log/docker
log_group_name = ${STACK_NAME}/EC2/${AUTOSCALING_GROUP}/var/log/docker
log_stream_name = {instance_id}
datetime_format = %Y-%m-%dT%H:%M:%S.%f

[/var/log/ecs/ecs-init.log]
file = /var/log/ecs/ecs-init.log.*
log_group_name = ${STACK_NAME}/EC2/${CLUSTER_NAME}/var/log/ecs/ecs-init
log_stream_name = {instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/ecs-agent.log]
file = /var/log/ecs/ecs-agent.log.*
log_group_name = ${STACK_NAME}/EC2/${CLUSTER_NAME}/var/log/ecs/ecs-agent
log_stream_name = {instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ
EOF

# Start services
sudo service awslogs start
sudo service docker start
sudo start ecs

# Exit gracefully if CLUSTER_NAME is not defined
if [[ -z $ECS_CLUSTER ]]
  then
  echo "Skipping ECS agent check as ECS_CLUSTER variable is not defined"
  exit 0
fi

# Loop until ECS agent has registered to ECS cluster
echo "Checking ECS agent is joined to $ECS_CLUSTER"
until [[ "$(curl --fail --silent http://localhost:51678/v1/metadata | jq '.Cluster // empty' -r -e)" == $ECS_CLUSTER ]]
  do printf '.'
  sleep 5
done
echo "ECS agent successfully joined to $ECS_CLUSTER"

# Pause if PAUSE_TIME is defined
if [[ -n $PAUSE_TIME ]]
  then
  echo "Pausing for $PAUSE_TIME seconds..."
  sleep $PAUSE_TIME
fi