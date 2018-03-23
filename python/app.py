#!/usr/bin/python

import json
import requests
import hmac
import base64
import time
from hashlib import sha512

tradingApiUrl = "https://api.crex24.com/CryptoExchangeService/BotTrade/"
apiKey = "your_api_key"
privateKey = "your_private_key"
nonce = 0


def getNonce():
    global nonce
    newNonce = int(time.time()) * 1000
    if newNonce > nonce:
        nonce = newNonce
    else:
        nonce += 1
    return nonce


def sendRequest(url, data):
    data["Nonce"] = getNonce()
    dataJsonStr = json.dumps(data, separators=(',', ':'))
    signature = createHash(dataJsonStr)
    headers = {
        "UserKey": apiKey,
        "Sign": signature
    }
    r = requests.post(tradingApiUrl + url, data=dataJsonStr, headers=headers)
    return r.json()


def createHash(dataJsonStr):
    key = base64.b64decode(privateKey)
    jsonBytes = bytes(dataJsonStr, "ascii")
    hmac_result = hmac.new(key, jsonBytes, sha512)
    return base64.b64encode(hmac_result.digest()).decode()


print("Let's make some requests...\n")

response = sendRequest("ReturnBalances", {
    "Names": ["BTC", "LTC"],
    "NeedNull": "true"
})
print("ReturnBalances response:", response)

response = sendRequest("ReturnOpenOrders", {
    "Pairs": ["BTC_LTC", "BTC_ETH"],
})
print("ReturnOpenOrders response: ", response)

print("\nNow you know how to request what you want!")
