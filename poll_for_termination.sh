#!/bin/sh

POLL_INTERVAL=${POLL_INTERVAL:-5}
while state=$(docker info -f '{{.Swarm.LocalNodeState}}'); [ ${state} == 'inactive' ]; do
  echo "Waiting to join swarm"
  sleep ${POLL_INTERVAL}
done
echo "Node is in swarm"

NODE_ID=$(docker info -f '{{.Swarm.NodeID}}')
NODE_IP=$(docker info -f '{{.Swarm.NodeAddr}}')

# Assume swarm HTTP API is exposed either through enabling it in daemon.json
# or using djenriquez/sherpa
API_PORT=${API_PORT:-4550}
MANAGER_IP=$(docker info -f '{{(index .Swarm.RemoteManagers 0).Addr}}' | sed -E 's/\:\d+//')

MANAGER_ADDR="tcp://$MANAGER_IP:$API_PORT"
# MANAGER_IP=$(docker info -f '{{json (index .Swarm.RemoteManagers 0).Addr}}')

NOTICE_URL=${NOTICE_URL:-http://169.254.169.254/latest/meta-data/spot/termination-time}

echo "Polling ${NOTICE_URL} every ${POLL_INTERVAL} second(s), Manager: ${MANAGER_ADDR}, Node: ${NODE_ID}"

while http_status=$(curl -o /dev/null -w '%{http_code}' -sL ${NOTICE_URL}); [ ${http_status} -ne 200 ]; do
  # echo $(date): ${http_status}
  sleep ${POLL_INTERVAL}
done

if [ "${SLACK_URL}" != "" ]; then
  SLACK_MESSAGE="Spot Termination Detected on node: $NODE_NAME"
  curl -X POST --data "payload={\"text\": \":warning: ${SLACK_MESSAGE}\"}" ${SLACK_URL}
fi

DOCKER_HOST=$MANAGER_ADDR docker node update --availability drain $NODE_ID
DOCKER_HOST=unix:///var/run/docker.sock docker swarm leave
DOCKER_HOST=$MANAGER_ADDR docker node rm --force $NODE_ID
