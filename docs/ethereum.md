# References
- [Robust JSON API Documentation](https://eth.wiki/json-rpc/API)
- [Walkthrough / Intro to Eth Transactions](https://kctheservant.medium.com/transactions-in-ethereum-e85a73068f74)
- [Personal API Namespace Reference (with example)](https://geth.ethereum.org/docs/rpc/ns-personal#personal_sendtransaction)

# Sending a Sample Transaction
This guide assumes that you already have an account with funds in it. This is a real transaction on the blockchain: [Check it out](https://www.etherchain.org/tx/30cf99e53211be1e7e1d84f18dda2f4b7ccd6d3c8947ac5a5c9359bb0a1fac40)!

*Create an account to receive the funds.*
```
$ geth account new --password <(echo "SamplePW")
INFO [11-17|22:26:33.961] Maximum peer count                       ETH=50 LES=0 total=50
INFO [11-17|22:26:33.961] Smartcard socket not found, disabling    err="stat /run/pcscd/pcscd.comm: no such file or directory"

Your new key was generated

Public address of the key:   0xaBf4530e5cf0dDb7B36B8c49131E28f106BfC831
Path of the secret key file: /home/vince/.ethereum/keystore/UTC--2021-11-18T03-26-33.961835019Z--abf4530e5cf0ddb7b36b8c49131e28f106bfc831

- You can share your public address with anyone. Others need it to interact with you.
- You must NEVER share the secret key with anyone! The key controls access to your funds!
- You must BACKUP your key file! Without the key, it's impossible to access account funds!
- You must REMEMBER your password! Without the password, it's impossible to decrypt the key!
```

All other commands are run using `geth attach` to start an interactive console.

*Confirm account addresses*
```js
> eth.accounts
["0x0b8dc010d117c760927e2d807827e24241499df2", "0xabf4530e5cf0ddb7b36b8c49131e28f106bfc831"]
```

*Create an object variable that represents the transaction. It will send 1 wei (the smallest amount of eth possible)*
```js
// create variable
> var tx = {"from": "0x0b8dc010d117c760927e2d807827e24241499df2", "to": "0xabf4530e5cf0ddb7b36b8c49131e28f106bfc831", "value": 1}
undefined
// confirm variable values
> tx.from
"0x0b8dc010d117c760927e2d807827e24241499df2"
> tx.to
"0xabf4530e5cf0ddb7b36b8c49131e28f106bfc831"
> tx.value
1
```

*Confirm that the PWs on file for **both** accounts work*
```js
> personal.sign("0x4869", tx.from, "SamplePW")
"0x84..1b" // yours will be different due to different private keys
> personal.sign("0x4869", tx.to, "SamplePW")
"0x92..bb" // yours will be different due to different private keys
```

*Confirm that sending the wrong PW will let us know there is a problem **immediately***
```js
> personal.sign("0x4869", tx.to, "WRONG-PW") // message signing
GoError: Error: could not decrypt key with given password at web3.js:6357:37(47)
        at github.com/ethereum/go-ethereum/internal/jsre.MakeCallback.func1 (native)
        at <eval>:1:32(6)
> personal.sendTransaction(tx, "WRONG-PW") //transaction sending
Error: could not decrypt key with given password
        at web3.js:6357:37(47)
        at send (web3.js:5091:62(35))
        at <eval>:1:25(5)
```

*Check the starting account balances and estimated gas required*
```js
> eth.estimateGas(tx) // Shows amount of gas required, but does not factor in gas price. Very annoying.
21000
> eth.getBalance(tx.from)
46446080000000000
> eth.getBalance(tx.to)
0
```

*Send the transaction*
```js
> personal.sendTransaction(tx, "SamplePW")
"0x30cf99e53211be1e7e1d84f18dda2f4b7ccd6d3c8947ac5a5c9359bb0a1fac40"
```

*Wait a few minutes, then check resulting account balances*
```js
> eth.getBalance(tx.from)
43659708406630999
> eth.getBalance(tx.to)
1
```

*See a transaction receipt. Note that with the current version of geth, I cannot use the `getTransactionByHash` endpoint*
```js
> eth.getTransactionReceipt("0x30cf99e53211be1e7e1d84f18dda2f4b7ccd6d3c8947ac5a5c9359bb0a1fac40")
{
  blockHash: "0x6392a56f856e02f467eb280aee25db7d321362d7a78e17b08d42441f022c1a64",
  blockNumber: 13642774,
  contractAddress: null,
  cumulativeGasUsed: 5076896,
  effectiveGasPrice: 132684361589,
  from: "0x0b8dc010d117c760927e2d807827e24241499df2",
  gasUsed: 21000,
  logs: [],
  logsBloom: "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  status: "0x1",
  to: "0xabf4530e5cf0ddb7b36b8c49131e28f106bfc831",
  transactionHash: "0x30cf99e53211be1e7e1d84f18dda2f4b7ccd6d3c8947ac5a5c9359bb0a1fac40",
  transactionIndex: 84,
  type: "0x2"
} //so no amount?! jeez. Need to use a separate blockchain explorer for this super basic functionality.
```