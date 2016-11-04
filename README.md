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
Initialize the private blockchain and set etherbase to mine to.
Don't forget to keep the private key.
```
docker-compose -f docker-compose.dev.yml -f docker-compose.yml run utils init
```
Run the image (remove -f docker-compose.dev.yml to run only an isolated geth
node).
```
docker-compose -f docker-compose.dev.yml -f docker-compose.yml up
```
# Useful commands
Attach to geth (where **DATA_DIR** should be remplaced by the appropriate value
from your docker-composer.yml file).
```
docker-compose -f docker-compose.dev.yml -f docker-compose.yml exec eth /geth attach ipc://DATA_DIR/datadir/geth.ipc
```
Build image (if you make modification).
```
cd eth-swarm && docker-compose -f docker-compose.dev.yml -f docker-compose.yml build
```
# Informations

Geth etherbase account is unlocked by default at launch, confusions can happen
if you have more than 1 account (check web3.eth.accounts).

Get a look at defaults configurations in docker-compose.* before starting.

See **GG_*** environment variables below for more genesis configurations and
default variables to set in docker-compose.dev.yml.
```
NAME:
   Genegis generator - Generate a generator

USAGE:
   genesis [global options] command [command options] [arguments...]

VERSION:
   0.1.0

COMMANDS:
     help, h  Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --nonce value          Nonce of the Genesis block (e.g: 0x0000000000000042) (default: "0x0000000000000042") [$GG_NONCE]
   

   --parent-hash value    Parent hash of the Genesis block should be equal to 0x0000000000000000000000000000000000000000000000000000000000000000 (default: "0x0000000000000000000000000000000000000000000000000000000000000000") [$GG_PARENT_HASH]
   

   --gas-limit value      Gas limit of the Genesis block (e.g: 0x8000000) (default: "0x8000000") [$GG_GAS_LIMIT]
   

   --mixhash value        Mixhash of the Genesis block (e.g: 0x0000000000000000000000000000000000000000000000000000000000000000) (default: "0x0000000000000000000000000000000000000000000000000000000000000000") [$GG_MIXHASH]
   

   --allocator value      Number allocator of the Genesis block (e.g: 1) (default: 1) [$GG_ALLOCATOR]
   

   --path-genesis value   Path to output the generated genesis configuration file (default: "./genesis.conf") [$GG_PATH_GENESIS]
   
   --path-to-pkeys value  Path to directory to put newly generated private key files, key files must not exists and directory must exists (e.g: /path/to/pkey/ (default: "./pkey") [$GG_PATH_PKEYS]

```

# Errors

```Error: Insufficient funds for gas * price + value```
You might running out of funds or mining may not have started due to DAG
generation, check logs.
