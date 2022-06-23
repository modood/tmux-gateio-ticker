#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

# get currency info by ticker name
# $1:       ticker_name       string
# return:   currency_info     json
#
# example:
#     $ currency "btc_usdt"
currency () {
  timeout 3 wget https://data.gate.io/api2/1/ticker/$1 -qO-
 #timeout 3 wget https://data.gateapi.io/api2/1/ticker/$1 -qO-
}

# get price from currency info
# $1:       currency_info     json
# return:   price             number
# example:
#     $ price `currency "btc_usdt"`
price () {
  echo $1 | grep -Po 'last[": ]+\K[^",]+'
}

# get percentage change from currency info
# $1:       currency_info     json
# return:   percentage        number
# example:
#     $ change `currency "btc_usdt"`
change () {
  echo $@ | grep -Po 'percentChange[": ]+\K[^",]+'
}

# formats a number using fixed-point notation
# $1:       number            number
# $2:       digits            number
# return:   number            number
# example:
#     $ tofixed 20222.328327482 4
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

# get ticker name from symbol name
# $1:       symbol_name       string
# return:   ticker_name       string
# example:
#     $ ticker "BTC/USDT"
ticker () {
  local s
  declare -l s # to upcase
  s=`echo "$1" | sed "s/\//_/g"`
  echo "$s"
}

option_currencies_default="BTC/USDT ETH/USDT@percent"
get_option_currencies () {
  echo `get_tmux_option "@gateio_ticker_currencies" "$option_currencies_default"`
}

out () {
  option_currencies=(`get_option_currencies`)
  for e in "${option_currencies[@]}"
  do
    IFS=@ a=($e)

    local symbol_name=${a[0]}
    local symbol_option=${a[1]}
    local ticker_name=`ticker "$symbol_name"`
    local currency_info=$(currency $ticker_name)

    local symbol_price=`tofixed $(price $currency_info) 4`
    if [ $symbol_option = percent ]
    then
      local symbol_price="$symbol_price "`tofixed $(change $currency_info) 2`%
    fi
    str="$str$symbol_name: $symbol_price, "
  done
  echo $(date +'%Y-%m-%d %H:%M:%S') ${str%,*}
}

main() {
  out 2> /dev/null
}
main
