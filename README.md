## Ethernaut Game: https://ethernaut.openzeppelin.com/

### CoinFlip level https://ethernaut.openzeppelin.com/level/0x6765a87878A413E0dEDEaAD34fbD8342a4300c56

Set up your `.env` file with:

```plaintext
ETH_RPC_URL=https://ethereum-holesky-rpc.publicnode.com
RAW_PRIVATE_KEY=your_private_key_here
COINFLIP_INSTANCE=address_of_the_CoinFlip_contract
COINFLIPGUESSER_INSTANCE=address_of_the_CoinFlipGuesser_contract
```

Deploy the CoinFlipGuesser Contract: `pnpm dotenv pnpm ethernaut:coinflip:deploy`
See wins count: `pnpm dotenv pnpm ethernaut:coinflip:wins`
Make a Guess 10 times: `pnpm dotenv pnpm ethernaut:coinflip:guess`, then continue with Ethernaut console.

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
