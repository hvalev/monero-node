# Full configurable ARMv7/ARM64/AMD64 Monero-Node

[![build](https://github.com/hvalev/monero-node/actions/workflows/build.yml/badge.svg)](https://github.com/hvalev/monero-node/actions/workflows/build.yml)
![monero%20version](https://img.shields.io/badge/monero%20version-0.18.0.0-green)
![Docker Pulls](https://img.shields.io/docker/pulls/hvalev/monero-node)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/hvalev/monero-node)

This docker image dockerizes a complete monero-node to use on ARMv7, ARM64 and AMD64 devices. It is fully configurable by overriding the containers' [config file](https://github.com/hvalev/monero-node/blob/main/monerod.conf). By default, this container will run a standard full node.


## How to run it with docker
The container can be started by simply running the following docker run command:
`docker run -v ~/monero/chain:/data -v ~/monero/log:/log -v ~/monero/monerod.conf:/monerod.conf --name monerod -p 18080:18080 hvalev/monero-node:latest`

or alternatively by using the following docker-compose configuration:
```
version: "3.6"
services:
  monerod:
    image: hvalev/monero-node:latest
    container_name: monerod
    ports:
    #monerod port
      - 18080:18080
    volumes:
      - ~/monero/chain:/data
      - ~/monero/log:/log
      #include only when you want to override the default config file
      #- ~/monero/monerod.conf:/monerod.conf
```

### Configuring your monero node
The node can be tuned by overriding the containers' configuration file `monerod.conf` using one on the host machine. Various configuration settings can be set, e.g. running a pruned-/archive-node and others. For more information check the official monero [configuration documentation](https://monerodocs.org/interacting/monero-config-file/) or one of the many online resources.

## Including a dashboard for your monero node
My [other respository](https://github.com/hvalev/monero-dashboard) contains an automatic build for a monero-node dashboard which binds to the local RPC service and visualizes various details about your running node. The dashboard is created by [jnbarlow](https://github.com/jnbarlow) and can be found in [this repository](https://github.com/jnbarlow/monero-dashboard). If you want to add the dashboard to your docker stack, use the following docker-compose file:
```
version: "3.6"
services:
  monerod:
    image: hvalev/monero-node:latest
    container_name: monerod
    ports:
    #monerod port
      - 18080:18080
    #monerod-gui port
      - 3000:3000
    volumes:
      - ~/monero/chain:/data
      - ~/monero/log:/log
      #include only when you want to override the default config file
      #- ~/monero/monerod.conf:/monerod.conf
  monerod-gui:
    image: hvalev/monero-dashboard:latest
    container_name: monerod-gui
    network_mode: service:monerod
    environment:
      - MONERO_HOST=0.0.0.0
      - MONERO_PORT=18081
      - TICKER=true
      - PORT=3000
    depends_on:
      - monerod
```
You can simply navigate to your host's IP:3000 to see the current status, connections to other nodes, database size and other information. The `network_mode: service:monerod` line essentially forces the GUI to run on the same network as the node container, allowing access to the nodes' localhost RPC service allowing seemless integration.

## Notes
Be aware that fully syncing a node from scratch may take multiple days and is affected by your internet connection and disk I/O speed (i.e. using an SSD to store the chain is almost a *prerequisite*). It is also possible to bootstrap the node by preloading most of the chain as elaborated on [here](https://www.getmonero.org/downloads/#blockchain). In addition, the full chain as of time of writing is approximately 150GB. Running a [pruned node](https://www.getmonero.org/resources/moneropedia/pruning.html) could make the chain take significantly less space.

## Acknowledgements
Naturally, all credit goes to the multiple contributors of the [monero project](https://github.com/monero-project/monero) as well as [jnbarlow](https://github.com/jnbarlow) for creating the monero node [dashboard](https://github.com/jnbarlow/monero-dashboard).
