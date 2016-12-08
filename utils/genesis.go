package main

import (
	"crypto/ecdsa"
	"crypto/rand"
	"fmt"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/crypto/secp256k1"
	"github.com/codegangsta/cli"
	"log"
	"os"
	"path"
	"encoding/json"
)

type Allocator struct {
	Code    string
	Storage map[string]string
	Balance string
}

type Genesis struct {
	Nonce       string
	Timestamp   string
	ParentHash  string
	ExtraData   string
	GasLimit    string
	Difficulty  string
	Mixhash     string
	Coinbase    string
	Alloc       map[string]Allocator
}

func NewAllocator(balance string) (string, string, *Allocator, error) {
	privateKey, err := ecdsa.GenerateKey(secp256k1.S256(), rand.Reader)
	if err != nil {
		return "", "", nil, err
	}
	address := crypto.PubkeyToAddress(privateKey.PublicKey)
	privHex := fmt.Sprintf("%064x", privateKey.D)
	allocator := Allocator{Code: "", Storage: nil, Balance: balance}
	return address.Hex(), privHex, &allocator, nil
}

func run(c *cli.Context) {
	var genesis Genesis

	genesis.Nonce = c.String("nonce")
	genesis.Timestamp = c.String("timestamp")
	genesis.ParentHash = c.String("parent-hash")
	genesis.GasLimit = c.String("gas-limit")
	genesis.Difficulty = c.String("difficulty")
	genesis.Mixhash = c.String("mixhash")

	genesis.Alloc = make(map[string]Allocator)
	for i := 0; i < c.Int("allocator"); i++ {
		address, privHex, allocator, err := NewAllocator(c.String("balance"))
		if err != nil {
			log.Println("NewAllocator", err)
			continue
		}
		pathToKey := path.Join(c.String("path-to-pkeys"), address)
		file, err := os.Create(pathToKey)
		if err != nil {
			log.Println("os.OpenFile", err)
			continue
		}
		if _, err = fmt.Fprintln(file, privHex); err != nil {
			log.Println("fmt.Fprintf", err)
		}
		if err_c := file.Close(); err_c != nil {
			log.Println("file.Close", err_c)
		}
		if err != nil {
			continue
		}
		log.Printf("Address: %v\tPrivate key: %v\n", address, privHex)
		genesis.Alloc[address] = *allocator
	}

	if len(genesis.Alloc) == 0 {
		log.Fatal("Allocators empty")
	}

	file, err := os.Create(c.String("path-genesis"))
	if err != nil {
		log.Println("os.OpenFile", err)
		return
	}
	defer file.Close()
	enc := json.NewEncoder(file)
	enc.Encode(&genesis)
}

func main() {
	app := cli.NewApp()
	app.Name = "Genegis generator"
	app.Usage = "Generate a generator"
	app.Version = "0.1.0"
	app.Action = run
	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:   "nonce",
			Usage:  "Nonce of the Genesis block (e.g: 0x0000000000000042)",
			Value:  "0x0000000000000042",
			EnvVar: "GG_NONCE",
		},
		cli.StringFlag{
			Name:   "timestamp",
			Usage:  "Timestamp of the Genesis block (e.g: 0x0)",
			Value:  "0x0", // TODO set to now()
			EnvVar: "GG_TIMESTAMP",
		},
		cli.StringFlag{
			Name:   "parent-hash",
			Usage:  "Parent hash of the Genesis block should be equal to 0x0000000000000000000000000000000000000000000000000000000000000000",
			Value:  "0x0000000000000000000000000000000000000000000000000000000000000000",
			EnvVar: "GG_PARENT_HASH",
		},
		cli.StringFlag{
			Name:   "extra-data",
			Usage:  "Extra data of the Genesis block (e.g: TODO)", //TODO
			Value:  "0x0",
			EnvVar: "GG_EXTRA_DATA",
		},
		cli.StringFlag{
			Name:   "gas-limit",
			Usage:  "Gas limit of the Genesis block (e.g: 0x8000000)",
			Value:  "0x8000000",
			EnvVar: "GG_GAS_LIMIT",
		},
		//TODO difficulty information
		cli.StringFlag{
			Name:   "difficulty",
			Usage:  "Difficulty of the Genesis block (e.g: 0x400)",
			Value:  "0x400",
			EnvVar: "GG_DIFFICULTY",
		},
		cli.StringFlag{
			Name:   "mixhash",
			Usage:  "Mixhash of the Genesis block (e.g: 0x0000000000000000000000000000000000000000000000000000000000000000)",
			Value:  "0x0000000000000000000000000000000000000000000000000000000000000000",
			EnvVar: "GG_MIXHASH",
		},
		cli.StringFlag{
			Name:   "coinbase",
			Usage:  "Coinbase of the Genesis block (e.g: 0x3333333333333333333333333333333333333333)",
			Value:  "0x3333333333333333333333333333333333333333",
			EnvVar: "GG_COINBASE",
		},
		cli.IntFlag{
			Name:   "allocator",
			Usage:  "Number allocator of the Genesis block (e.g: 1)",
			Value:  1,
			EnvVar: "GG_ALLOCATOR",
		},
		cli.StringFlag{
			Name:   "balance",
			Usage:  "Balance for each allocator in the Genesis block (e.g: 20000000000000000000)",
			Value:  "20000000000000000000",
			EnvVar: "GG_BASE_BALANCE",
		},
		cli.StringFlag{
			Name:   "path-genesis",
			Usage:  "Path to output the generated genesis configuration file",
			Value:  "./genesis.conf",
			EnvVar: "GG_PATH_GENESIS",
		},
		cli.StringFlag{
			Name:   "path-to-pkeys",
			Usage:  "Path to directory to put newly generated private key files, key files must not exists and directory must exists (e.g: /path/to/pkey/",
			Value:  "./pkey",
			EnvVar: "GG_PATH_PKEYS",
		},
	}
	app.Run(os.Args)
}
