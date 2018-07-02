import datetime
import base64
import hmac
import json
from hashlib import sha512
from urllib.request import urlopen, Request
from urllib.error import HTTPError

baseUrl = "https://api.crex24.com"
apiKey = "<Your API key>"
secret = "<Your secret>"

path = "/v2/trading/placeOrder"
body = json.dumps({
    "instrument": "ETH-BTC",
    "side": "sell",
    "volume": 1,
    "price": 12345.67
}, separators=(',', ':'))
nonce = round(datetime.datetime.now().timestamp() * 1000)

key = base64.b64decode(secret)
message = str.encode(path + str(nonce) + body, "utf-8")
hmac = hmac.new(key, message, sha512)
signature = base64.b64encode(hmac.digest()).decode()

request = Request(baseUrl + path)
request.method = "POST"
request.data = str.encode(body, "utf-8")
request.add_header("User-Agent", "script")
request.add_header("Content-Length", len(body))
request.add_header("X-CREX24-API-KEY", apiKey)
request.add_header("X-CREX24-API-NONCE", nonce)
request.add_header("X-CREX24-API-SIGN", signature)

try:
    response = urlopen(request)
except HTTPError as e:
    response = e

status = response.getcode()
body = bytes.decode(response.read())

print("Status code: " + str(status))
print(body)
