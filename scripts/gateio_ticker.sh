#!/usr/bin/env bash

print_price () {
    # todo
    date "+%Y-%m-%d %H:%M:%S" | cut -d ":" -f1,2,3
}

main() {
	print_price
}
main
