#!/bin/bash
# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=100:

. stty.sh
. lineio.sh

function atcommand()
{
  local -i n
  for ((n = 1; n <= 3; ++n))
  do
    send "$1"
    while recv 5
    do
      case "$REPLY" in
        "${2:-OK}")
          return 0
          ;;
      esac
    done
  done
  return 1
}

cerr Connecting...
atcommand ATD
atcommand ATI ELM327

#while true
#do
#  send 2101
#  send 2102
#  send 2103
#  send 2104
#  send 2105
#  recv can isotp
#done
