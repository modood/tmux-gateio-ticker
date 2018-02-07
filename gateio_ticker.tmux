#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/scripts/helpers.sh"

gateio_ticker="#($CURRENT_DIR/scripts/gateio_ticker.sh)"
gateio_ticker_interpolation="\#{gateio_ticker}"

do_interpolation() {
	local string=$1
	local all_interpolated=${string/$gateio_ticker_interpolation/$gateio_ticker}
	echo $all_interpolated
}

update_tmux_option() {
	local option=$1
	local option_value=$(get_tmux_option "$option")
	local new_option_value=$(do_interpolation "$option_value")
	set_tmux_option "$option" "$new_option_value"
}

main() {
	update_tmux_option "status-right"
	update_tmux_option "status-left"
}
main
