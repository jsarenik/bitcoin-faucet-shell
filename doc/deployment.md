# Deploying bitcoin-faucet-shell

## Overview

 - understand the pillars
 - generate keys and edit configuration files
 - run busybox httpd
 - run sff-loop.sh

## Keys

Let's start with generating a random new testnet key:


```
$ hal -t key generate
{
  "raw_private_key": "a99a658cb425f7e4eca749ee4f1198cdfb1d797716d6573affe4818586bef682",
  "wif_private_key": "cTGPTExB3y45JNFMxRRDKKXfycqS3YswAidzVrdJUPeZ1XZwVcXF",
  "uncompressed_wif_private_key": "92scStC9Ajc8miWzJzeCrTrYVEZGeHHXQ3dvosDJZ2xdhzA9Rik",
  "public_key": "03e1de1b747fc4ca7d489d38b383dc464d9ef157bb673ef77e9d16645180113606",
  "xonly_public_key": "e1de1b747fc4ca7d489d38b383dc464d9ef157bb673ef77e9d16645180113606",
  "uncompressed_public_key": "04e1de1b747fc4ca7d489d38b383dc464d9ef157bb673ef77e9d16645180113606cc9a46bbeff7c450257ae5fe2ec1fd90c13c396d3215e71f1e51a92a32c30dbd",
  "addresses": {
    "p2pkh": "n2ESfpVc6XSQve6uYvBtisoZoQd7FVd2W5",
    "p2wpkh": "tb1quva5rtlksj70uttmzhzt60pktvp6mrk9dda95h",
    "p2shwpkh": "2N5ksGq7m3Ws6mVUjyTGxFwi78vZ4BkxUCg",
    "p2tr": "tb1p9et839g5adwnh5zajyzdt8y8v623l2hk0vmq0at5agc2a6jn2pqsl3jzsu"
  }
}
```

Now make a `mytestkeys` plain-text file containing following variables:

```
privkey=wif_private_key
uncom=uncompressed_wif_private_key

lmabi=another_randomly_generated_wif_private_key
privkeyo=yet_another_like_above

dt=set_to_listdescriptors_true_output_plain_text_file_path
```

Generate wallets for those keys and descriptors using `refreshsignetwallets.sh` script.

## Work in Progress ...
