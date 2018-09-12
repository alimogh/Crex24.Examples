library(jsonlite)
library(RCurl)
library(digest)

tradingApiUrl <- "https://api.crex24.com/CryptoExchangeService/BotTrade/"
apiKey <- 'your_api_key' #insert your key 
privateKey <- 'your_private_key' #insert your secret

nonce <- 0

getNonce <- function() {
  newNonce <- as.integer(as.POSIXct(Sys.time())) * 1000
  if (newNonce > nonce) {
    nonce <<- newNonce
  } else {
    nonce <<- nonce + 1
  }
  nonce
}

createHash <- function(dataJsonStr) {
  key = base64Decode(privateKey)
  base64Encode(hmac(key = key, object = dataJsonStr, algo = "sha512", 
    serialize = FALSE, raw = TRUE))
}

sendRequest <- function(url, data) {
  data = c(data, Nonce = getNonce())
  dataJsonStr <- toJSON(data, auto_unbox = TRUE, pretty = FALSE)
  signature = createHash(as.character(dataJsonStr))
  
  ch = getCurlHandle()
  curlSetOpt(.opts = list(postfields = dataJsonStr, httpheader = c(c(UserKey = apiKey, 
    Sign = signature)), verbose = FALSE), .forceHeaderNames = TRUE, 
    curl = ch)
  ans = getURL(paste0(tradingApiUrl, url), curl = ch)
  
  fromJSON(ans)
}

cat("Let's make some requests...\n")

cat("ReturnBalances:\n")
response = sendRequest("ReturnBalances", c(list(Names = c("BTC", 
  "LTC")), NeedNull = "true"))
str(response)

cat("ReturnOpenOrders:\n")
response = sendRequest("ReturnOpenOrders", list(Pairs = list("BTC_LTC", 
  "BTC_ETH")))
str(response)

cat("Now you know how to request what you want!\n")
