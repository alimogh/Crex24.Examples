import datetime
import base64
import hmac
from hashlib import sha512
from urllib.request import urlopen, Request
from urllib.error import HTTPError

baseUrl = "https://api.crex24.com"
apiKey = "<Your API key>"
secret = "<Your secret>"

path = "/v2/account/balance?currency=BTC"
nonce = round(datetime.datetime.now().timestamp() * 1000)

key = base64.b64decode(secret)
message = str.encode(path + str(nonce), "utf-8")
hmac = hmac.new(key, message, sha512)
signature = base64.b64encode(hmac.digest()).decode()

request = Request(baseUrl + path)
request.method = "GET"
request.add_header("User-Agent", "script")
request.add_header("X-CREX24-API-KEY", apiKey)
request.add_header("X-CREX24-API-NONCE", nonce)
request.add_header("X-CREX24-API-SIGN", signature)

try: 
    response = bytes.decode(urlopen(request).read())
    print(response)
except HTTPError as e: 
    print(bytes.decode(e.read()))