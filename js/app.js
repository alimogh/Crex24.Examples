const axios = require("axios");
const crypto = require("crypto");
/**
 * CREX24 api example
 */
const tradingApiUrl = "https://api.crex24.com/CryptoExchangeService/BotTrade/";
const apiKey = "your_api_key";
const privateKey = "your_private_key"

async function main() {
    console.log("Let's make some requests...\n")

    const balances = await sendRequest("ReturnBalances", {
        Names: ["BTC", "LTC"],
        NeedNull: true,
    });
    console.log("ReturnBalances response:", balances.data);

    const openOrders = await sendRequest("ReturnOpenOrders", {
        Pairs: ["BTC_LTC", "BTC_ETH"],
    });
    console.log("ReturnOpenOrders response:", openOrders.data);

    console.log("\nNow you know how to request what you want!")
}

async function sendRequest(url, requestPayload) {
    const payload = {
        ...requestPayload,
        Nonce: getCurrentNonce(),
    };
    const hash = await createHash(payload);

    return axios({
        headers: {
            UserKey: apiKey,
            Sign: hash,
        },
        method: "post",
        data: payload,
        url: tradingApiUrl + url,
    });
}

async function createHash(requestPayload) {
    const hmac = crypto.createHmac("sha512", Buffer.from(privateKey, "base64"));
    const bytes = Buffer.from(JSON.stringify(requestPayload));
    hmac.update(bytes);
    return hmac.digest("base64");
}

var currentNonce = 0;
function getCurrentNonce() {
    var newNonce = Date.now();
    if (newNonce > currentNonce) {
        currentNonce = newNonce;
    } else {
        currentNonce += 1;
    }
    return currentNonce;
}

main();
