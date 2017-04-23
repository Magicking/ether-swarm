Ether-swarm
===================

This repository aims to ease the use of creating a private ethereum blockchain using docker and scripts.

Requirements:

  * Docker
  * Docker Compose

See https://docs.docker.com/compose/install/

# How to create a private ethereum blockchain 

Clone the repository and change your work directory.
```
git clone https://github.com/Magicking/ether-swarm.git
cd ether-swarm
```
Initialize submodules
```
git submodule update --init --recursive
```

# Useful commands

Init and update sudmodule

# Informations

How to use ?

```
docker-compose up
```

Initialize the private blockchain see ether-swarm-services documentation
```
curl -v -X POST http://127.0.0.1:8090/blockchain/create
```

Access ethnetstat @ & useful URI @

```
eth-netstat: http://127.0.0.1:41234/stats/
explorer: http://127.0.0.1:41234/explorer/
browser-solidity: http://127.0.0.1:41234/
```

# Errors

```Error: Insufficient funds for gas * price + value```
You might running out of funds or mining may not have started due to DAG
generation, check logs.
