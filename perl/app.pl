use strict;

use Digest::SHA qw(hmac_sha512_base64);
use MIME::Base64;
use LWP::UserAgent;
use JSON;
use Data::Dumper;

my $tradingApiUrl = "https://api.crex24.com/CryptoExchangeService/BotTrade/";
my $apiKey     = "your_api_key";
my $privateKey = "your_private_key";

my $Nonce = 0;

sub getNonce {
  my $newNonce = time() * 10;
  if ( $newNonce > $Nonce ) {
    $Nonce = $newNonce;
  } else {
    $Nonce += 1;
  }
  return $Nonce;
}

sub createHash {
  my ($dataJsonStr) = @_;

  my $key = decode_base64($privateKey);
  my $hmac_result = hmac_sha512_base64( $dataJsonStr, $key );

  # Fix padding of Base64 digests
  while ( length($hmac_result) % 4 ) {
    $hmac_result .= '=';
  }

  return $hmac_result;
}

sub sendRequest {
  my ( $url, $DATAhashPtr ) = @_;

  my %DATAhash = %$DATAhashPtr;
  $DATAhash{'Nonce'} = getNonce();

  my $dataJsonStr = encode_json \%DATAhash;
  my $signature   = createHash($dataJsonStr);

  my $req = HTTP::Request->new( 'POST', "$tradingApiUrl$url" );
  $req->header(
    'UserKey' => $apiKey,
    'Sign'    => $signature
  );
  $req->content($dataJsonStr);

  my $lwp = LWP::UserAgent->new;
  my $res = $lwp->request($req);

  if ( $res->is_success() ) {
    return decode_json $res->content;
  } else {
    die ( "ERROR: " . $res->status_line() . "\n" );
  }
}


print("Let's make some requests...\n");

my $response = sendRequest(
  "ReturnBalances",
  {
    "Names"    => ["BTC", "LTC"],
    "NeedNull" => "true"
  }
);
print( "ReturnBalances response: ", Dumper $response, "\n" );

$response = sendRequest(
  "ReturnOpenOrders",
  {
    "Pairs" => ["BTC_LTC", "BTC_ETH"],
  }
);
print( "ReturnOpenOrders response: ", Dumper $response, "\n" );

print("Now you know how to request what you want!\n");
