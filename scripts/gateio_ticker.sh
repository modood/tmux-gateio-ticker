#!/usr/bin/env bash

fetch () {
  timeout 1 wget http://data.gate.io/api2/1/tickers -qO-
}

fetch_single () {
  timeout 1 wget http://data.gate.io/api2/1/ticker/$1 -qO-
}

currency () {
  echo $1 | grep -Po $2'["{: ]+\K[^}]+'
}

price () {
  echo $1 | grep -Po 'last[": ]+\K[^",]+'
}

change () {
  echo $1 | grep -Po 'percentChange[": ]+\K[^",]+'
}

out () {
  data=`fetch`

  btc=`currency $data btc_usdt`
  btc_usdt=`price $btc`

  usdt=`fetch_single usdt_cny`
  usdt_cny=`price $usdt`

  btc_cny=$(echo "$btc_usdt * $usdt_cny" | bc)

  xrp=`currency $data xrp_usdt`
  xrp_change=`change $xrp`
  xrp_change=$(echo "scale=2;$xrp_change/1" | bc)

  doge=`currency $data doge_usdt`
  doge_change=`change $doge`
  doge_change=$(echo "scale=2;$doge_change/1" | bc)

  if [ -n "$data" ]
  then
    if [ -n "$btc_cny" ]
    then
      echo btc: ¥$btc_cny, xrp: $xrp_change%, doge: $doge_change% > $HOME/.gateio_ticker
    else
      echo btc: \$$btc_usdt, xrp: $xrp_change%, doge: $doge_change% > $HOME/.gateio_ticker
    fi
  fi

  cat $HOME/.gateio_ticker
}

main() {
  out 2> /dev/null
}

main
