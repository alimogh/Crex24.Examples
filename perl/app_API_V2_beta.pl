#!/usr/bin/perl -w

use strict;

use Digest::SHA qw(hmac_sha512_base64);
use MIME::Base64 qw(decode_base64);
use LWP::UserAgent;
use JSON;
use Data::Dumper;

my $test = 0;

my $tradingApiUrl = "https://api.crex24.com"; # Trade API 2.0 (Beta)
my $apiKey     = "your_api_key";
my $privateKey = "your_private_key";

my $request_rate_quota = 6;                   # Maximum 6 requests per second

my $Nonce = time() * $request_rate_quota;

sub getNonce {
  my $newNonce = time() * $request_rate_quota;
  if ( $newNonce > $Nonce ) {
    $Nonce = $newNonce;
  } else {
    $Nonce += 1;
    print "limiting the rate of requests per second.\n" && sleep 1 if $newNonce - $Nonce > $request_rate_quota;
  }
  return $Nonce;
}

sub createHash {
  my ( $privateKey, $dataJsonStr ) = @_;

  my $hmac_result = hmac_sha512_base64( $dataJsonStr, decode_base64($privateKey) );

  # Fix padding of Base64 digests
  while ( length($hmac_result) % 4 ) {
    $hmac_result .= '=';
  }

  return $hmac_result;
}

sub sendRequest {
  my ($path) = @_;

  my $nonce = getNonce();
  my $signature = createHash( $privateKey, "$path$nonce" );

  my $req = HTTP::Request->new( 'GET', "$tradingApiUrl$path" );
  $req->header(
    'X-CREX24-API-KEY'   => $apiKey,
    'X-CREX24-API-NONCE' => $nonce,
    'X-CREX24-API-SIGN'  => $signature,
  );

  my $lwp = LWP::UserAgent->new;
  my $res = $lwp->request($req);

  if ( $res->is_success() ) {
    return decode_json $res->content;
  } else {
    die( "ERROR: " . $res->status_line() . "\n" );
  }
}

print("Let's make some requests...\n");

my $response = sendRequest("/v2/account/balance");
print( "balance response: ", Dumper $response, "\n" );

$response = sendRequest("/v2/trading/activeOrders");
print( "activeOrders response: ", Dumper $response, "\n" );

print("Now you know how to request what you want!\n");
