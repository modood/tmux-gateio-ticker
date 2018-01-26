#!/usr/bin/env bash

# return: currencies
fetch () {
  timeout 1 wget http://data.gate.io/api2/1/tickers -qO-
}

# $1:     currency name
# return: currency
fetch_single () {
  timeout 1 wget http://data.gate.io/api2/1/ticker/$1 -qO-
}

# $1:     currencies
# $2:     currency name
# return: currency
currency () {
  echo $1 | grep -Po $2'["{: ]+\K[^}]+'
}

# $1:     currency
# return: number
price () {
  echo $1 | grep -Po 'last[": ]+\K[^",]+'
}

# $1:     currency
# return: number
change () {
  echo $1 | grep -Po 'percentChange[": ]+\K[^",]+'
}

# $1:     number
# $2:     digits
# return: number
tofixed () {
  local f=`echo "scale=$2;$1/1" | bc`
  local gt=`echo "$f > -1" | bc`
  local lt=`echo "$f < 1" | bc`
  local gt0=`echo "$f > 0" | bc`

  if [[ $gt -eq 1 && $gt0 -eq 0 ]]
  then
    # number -0.2 look like -.2
    echo -0.${f:2:`echo "2 + $2" | bc`}
  elif [[ $lt -eq 1 && $gt0 -eq 1 ]]
  then
    # number 0.2 look like .2
    echo 0$f
  else
    # default do nothing
    echo $f
  fi
}

out () {
  digits=4
  currencies=`fetch`
  cachefile=$HOME/.gateio_ticker

  local btc_usdt=`tofixed $(price $(currency $currencies btc_usdt)) $digits`
  local btc_cny=`tofixed $(echo "$btc_usdt * $(price $(fetch_single usdt_cny))" | bc) $digits`
  local xrp_change=`tofixed $(change $(currency $currencies xrp_usdt)) $digits`
  local doge_change=`tofixed $(change $(currency $currencies doge_usdt)) $digits`

  if [ -n "$currencies" ]
  then
    if [ -n "$btc_cny" ]
    then
      echo BTC/CNY: ¥$btc_cny, XRP/USDT: $xrp_change%, DOGE/USDT: $doge_change% > $cachefile
    else
      echo BTC/USD: \$$btc_usdt, XRP/USDT: $xrp_change%, DOGE/USDT: $doge_change% > $cachefile
    fi
  fi

  cat $cachefile
}

main() {
  out 2> /dev/null
}

main
