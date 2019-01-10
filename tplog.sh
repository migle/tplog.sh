#!/bin/bash
# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=100:

. stty.sh
. lineio.sh

function expect()
{
  local REPL="${1:-OK}"
  while recv 5
  do
    cerr REPL: "$REPLY" "($REPL)"
    case "$REPLY" in
      $REPL*)
        cerr BINGO!
        return 0
        ;;
      "?")
        send ""
        ;;
      *)
        examine "$REPLY"
        ;;
    esac
  done
  return 1
}

function atcommand()
{
  local -i n
  for ((n = 1; n <= 3; ++n))
  do
    cerr SEND: "$1"
    send "$1"
    expect "${2:-OK}" && return 0
  done
  return 1
}

cerr Connecting...
send ""
expect MIGUEL
atcommand ATD
atcommand ATE0
atcommand ATL0
atcommand ATH1
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
