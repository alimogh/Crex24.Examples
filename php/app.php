<?php
// crex 24 bot trade api requests example with authentication via hmacsha512 signature
//
// tested with php version:
// PHP 7.1.15-0ubuntu0.17.10.1 (cli) (built: Mar 14 2018 22:30:42) ( NTS )
// Copyright (c) 1997-2018 The PHP Group
// Zend Engine v3.1.0, Copyright (c) 1998-2018 Zend Technologies
// with Zend OPcache v7.1.15-0ubuntu0.17.10.1, Copyright (c) 1999-2018, by Zend Technologies

$trading_api_url = "https://api.crex24.com/CryptoExchangeService/BotTrade/";
$api_key = "your_api_key";
$private_api_key = "your_private_key";
$currentNonce = 0;


echo ("Let's send some requests...\n\n");

$requestParams = array(
    "Names" => array("BTC", "LTC"),
    "NeedNull" => true,
);
$result = sendRequest("ReturnBalances", $requestParams);
echo ("ReturnBalances result: ");
var_dump($result);


$requestParams = array(
    "Pairs" => array("BTC_LTC", "BTC_ETH"),
);
$result = sendRequest("ReturnOpenOrders", $requestParams);
echo ("ReturnOpenOrders result: ");
var_dump($result);

echo ("\nNow you know how to request what you want!\n");



// for windows systems you probably need to uncomment php_openssl.dll extension line in php.ini
// for unix systems check is openssl installed
//
// this function returns associative array or null
function sendRequest($apiMethod, $requestParams)
{
    global $trading_api_url;
    global $api_key;

    $requestParams["Nonce"] = getCurrentNonce();

    // don't change params after this line
    $requestPayloadStr = json_encode($requestParams);
    // generate sign for
    $sign = createSign($requestPayloadStr);

    $reqOptions = array(
        "http" => array(
            "header" => "Content-Type: application/json\r\n" .
            "Sign:" . $sign . "\r\n" .
            "UserKey:" . $api_key . "\r\n",
            "method" => "POST",
            "content" => $requestPayloadStr,
        ),
    );

    $context = stream_context_create($reqOptions);
    $result = file_get_contents($trading_api_url . $apiMethod, false, $context);

    if ($result === false) {
        return null;
    }
    return json_decode($result, true);
}

function createSign($message)
{
    global $private_api_key;

    $decodedPk = base64_decode($private_api_key);
    $rawHash = hash_hmac("sha512", $message, $decodedPk, true); // set param raw_output for hash_hmac function always TRUE
    $base64EncodedHash = base64_encode($rawHash);

    return $base64EncodedHash;
}

function getCurrentNonce()
{
    global $currentNonce;

    $newNonce = round(microtime(true) * 1000);
    if ($newNonce > $currentNonce) {
        $currentNonce = $newNonce;
    } else {
        $currentNonce += 1;
    }
    return $currentNonce;
}

?>