#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

# return: currencies
fetch () {
  timeout 1 wget http://data.gateio.io/api2/1/tickers -qO-
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
  echo $@ | grep -Po 'percentChange[": ]+\K[^",]+'
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

# $1:     string
# return: string
symbol () {
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
  digits=4
  currencies=`fetch`
  cachefile=$HOME/.gateio_ticker

  option_currencies=`get_option_currencies`
  option_currencies=($option_currencies)

  # ensure response is valid
  local btc=`echo $currencies | grep -Po '\"btc_usdt\"'`
  if [ -n "$btc" ]
  then
    local all=`change $(echo $(currency $currencies '_usdt"'))`
    local rise=0
    local fall=0
    all=($all)
    for f in ${all[@]}
    do
      local gt0=`echo "$f > 0" | bc`
      local lt0=`echo "$f < 0" | bc`
      if [[ $gt0 -eq 1 ]]
      then
        let rise++
      elif [[ $lt0 -eq 1 ]]
      then
        let fall++
      fi
    done
    local str="MARKET: $rise↑ $fall↓, "

    for e in "${option_currencies[@]}"
    do
      IFS=@ a=($e)

      local c=${a[0]}
      local t=${a[1]}
      local s=`symbol "$c"`

      local p=`tofixed $(price $(currency $currencies \"$s\")) $digits`
      if [ $t = percent ]
      then
        local p="$p "`tofixed $(change $(currency $currencies \"$s\")) $digits`%
      fi
      str="$str$c: $p, "
    done
    echo ${str%,*} > $cachefile
  fi

  cat $cachefile
}

main() {
  out 2> /dev/null
}
main
