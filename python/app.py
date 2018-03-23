#!/usr/bin/python

import json
import requests
import hmac
import base64
import time
from hashlib import sha512

tradingApiUrl = "https://api.crex24.com/CryptoExchangeService/BotTrade/"
apiKey = "1cc34223-37e8-49f3-a5bd-394ba25bf853"
privateKey = "Jpm/Ua6K2A5Fhq5iYQen3KvM4blhEUaTzH+r5i6xTGhdYzyapyyr1K/FHNrCx6ESG86V5erKBpC4j1dv/a8Uiw=="
nonce = 0

print("Crex24 examples")


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
    headers = {
        "Content-Type": "application/json",
        "UserKey": apiKey,
        "Sign": createHash(data),
        }
    r = requests.post(tradingApiUrl + url, data=data, headers=headers)
    return r.json()


def createHash(data):
    hmacInstance = hmac.new(base64.b64decode(privateKey), digestmod=sha512)
    hmacInstance.update(json.dumps(data).encode(encoding="ascii"))
    result = base64.encodebytes(hmacInstance.digest()).decode("ascii")
    print(result)
    #result = result[:len(result) - 1]
    return result


response = sendRequest("ReturnBalances", {
    "Names": ["BTC", "LTC"],
    "NeedNull": "true"
})
print("Response: ", response)
