#!/usr/bin/R --vanilla -f

library(jsonlite)
library(RCurl)
library(digest)

tradingApiUrl <- "https://api.crex24.com"         # Trade API 2.0 (Beta)
apiKey     <- ""  # insert your key
privateKey <- ""  # insert your secret

request_rate_quota <- 6

nonce <- as.integer(as.POSIXct(Sys.time())) * 6

getNonce <- function() {
  newNonce <- as.integer(as.POSIXct(Sys.time())) * 6
  if (newNonce > nonce) {
    nonce <<- newNonce
  } else {
    nonce <<- nonce + 1
    if (newNonce - nonce > request_rate_quota) {
      cat("limiting the rate of requests per second.\n") 
      Sys.sleep(1)
    }
  }
  nonce
}


sendRequest <- function(path, data) {
  Nonce = getNonce()
  
  signature = base64Encode(hmac(key = base64Decode(privateKey), 
    object = paste0(path, Nonce), algo = "sha512", serialize = FALSE, 
    raw = TRUE))
  
  ch = getCurlHandle()
  curlSetOpt(.opts = list(httpheader = c(c(`X-CREX24-API-KEY` = apiKey, 
    `X-CREX24-API-NONCE` = Nonce, `X-CREX24-API-SIGN` = signature)), 
    verbose = FALSE), .forceHeaderNames = TRUE, curl = ch)
  ans = getURL(paste0(tradingApiUrl, path), curl = ch)
  
  fromJSON(ans)
}

cat("Let's make some requests...\n")

cat("balance:\n")
response = sendRequest("/v2/account/balance", "")
str(response)

cat("activeOrders:\n")
response = sendRequest("/v2/trading/activeOrders", "")
str(response)

cat("Now you know how to request what you want!\n")
