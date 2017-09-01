# Swarm spot instance graceful shutdown

In AWS when a spot instance receives a shutdown notification, this image
drains the node and removes the instance from swarm

## Usage

On node startup run:

```sh
docker run -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  shapigor/swarm-aws-spot-terminator
```

## Usage in user data

```sh
docker run \
    --restart=always -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    shapigor/swarm-aws-spot-terminator
```
