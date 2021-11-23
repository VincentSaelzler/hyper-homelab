# Testing Wallet Backups and PWs
Sending transactions in *not* a great way to test
1. It requires transaction fees
1. The client automatically generates change addresses (and for some reason a blank one?) which makes the wallet files bigger and more confusing.

Test by signing messages instead. The CLI signing was confusing, so I used the GUI.

Note that even for dramatically different lenghts of message, the signature is the same.
# Saving Backups
**Saving a brand new backup every time a transaction happens is critical!** That's because the unspent coin goes to a change address. It does **NOT** stay in the original account. Therefore, the private key of the old account becomes worthless.

# Upgrade and Encrypt Wallet
```js
~/bitcoin/src/bitcoin-cli upgradewallet
{
  "wallet_name": "",
  "previous_version": 130000,
  "current_version": 169900,
  "result": "Wallet upgraded successfully from version 130000 to version 169900."
}
~/bitcoin/src/bitcoin-cli upgradewallet
{
  "wallet_name": "",
  "previous_version": 169900,
  "current_version": 169900,
  "result": "Already at latest version. Wallet version unchanged."
}
~/bitcoin/src/bitcoin-cli encryptwallet "SamplePW"
wallet encrypted; The keypool has been flushed and a new HD seed was generated (if you are using HD). You need to make a new backup.
```
# Get Details About the Addresses
```js
./bitcoin-cli listlabels
[
  "",
  "MNG-2016-2017"
]
./bitcoin-cli getaddressesbylabel ""
{
  "12Wz25d4YuADHXMK8UQ4YqmJ9HJ9PYbcJW": {
    "purpose": "receive"
  }
}
./bitcoin-cli getaddressesbylabel "MNG-2016-2017"
{
  "1NLXUBEc5MgDyuqXJCdmN8ieVJSduB8Bfu": {
    "purpose": "receive"
  }
}
./bitcoin-cli getbalances
{
  "mine": {
    "trusted": 0.04504172,
    "untrusted_pending": 0.00000000,
    "immature": 0.00000000
  }
}
```
# Confirm Encryption Works
```js
./bitcoin-cli dumpprivkey 12Wz25d4YuADHXMK8UQ4YqmJ9HJ9PYbcJW //should NOT work
error code: -13
error message:
Error: Please enter the wallet passphrase with walletpassphrase first.

./bitcoin-cli walletpassphrase "SamplePW" 60 //now dumpprivkey will work for 60 seconds
```
# Send Test Transaction
I was unable to figure out how to send a test transaction with CLI only, so used GUI.

Sending 1 Satoshi is not possible. That's because there is a hard-coded limit in the clients (not protocol) to avoid "dust" transactions. I couldn't figure out exactly what it is, but I think around 500 Satoshis.

After doing a test transaction of 1000 Satoshis (less txn fee) here were the balances.
```js
// this is the total amount recieved (not the NET amount/balance)
./bitcoin-cli listreceivedbyaddress
[
  {
    "address": "12Wz25d4YuADHXMK8UQ4YqmJ9HJ9PYbcJW",
    "amount": 0.00000571,
    "confirmations": 8,
    "label": "One Thousand Satoshi",
    "txids": [
      "1664021009c12958f061990e1a5ea61fb57a3db54bf34bb7c7e6c0d755f3ed75"
    ]
  },
  {
    "address": "1NLXUBEc5MgDyuqXJCdmN8ieVJSduB8Bfu",
    "amount": 0.04504172,
    "confirmations": 244295,
    "label": "MNG-2016-2017",
    "txids": [
      "d705b1089a8a92a45c987a0ddf2fba6176df54de2919f37cc8144aa293b67a1f"
    ]
  }
]
// address groupings has the right balances
./bitcoin-cli listaddressgroupings
[
  [
    [
      "12Wz25d4YuADHXMK8UQ4YqmJ9HJ9PYbcJW",
      0.00000571,
      "One Thousand Satoshi"
    ]
  ],
  [
    [
      "1NLXUBEc5MgDyuqXJCdmN8ieVJSduB8Bfu",
      0.00000000,
      "MNG-2016-2017"
    ],
    [ //this one got auto created. why?
      "36DKYzMitxMxP77p7DszTB6KFfFkyCvQyy",
      0.00000000
    ],
    [ //this one got auto-created as a change address
      "bc1qucvkd08s3qeepnpy49mxnd55jjz0wq0nclu8f3",
      0.04073172
    ]
  ]
]
```
