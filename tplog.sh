#!/bin/bash
# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=100:

LOG=$(date +can_%Y-%m-%d_%H-%M-%S.log)

. lineio.sh

function expect()
{
  local REPL="${1:-OK}"
  while recv 5
  do
    cerr REPL: "$REPLY" "($REPL)"
    case "${REPLY#>}" in
      $REPL*)
        return 0
        ;;
      ""|"$2")
        ;;
      "?")
        return 1
        ;;
      *)
        cerr BAD!
        examine "$REPLY"
        return 1
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
    expect "${2:-OK}" "$1" && return 0
  done
  return 1
}

function readdata()
{
  while recv 0.2
  do
    cerr DATA: "$REPLY"
    case "${REPLY#>}" in
      "STOPPED"*|"NO DATA"*)
        return 1
        ;;
      [0-9A-F][0-9A-F][0-9A-F]*)
        echo ${TIMESTAMP} ${REPLY#>} >> ${LOG}
        echo ${TIMESTAMP} ${REPLY#>}
        ;;
    esac
  done
  return 1
}

cerr Connected.
send $'\r'
expect MIGUEL
atcommand ATD
atcommand ATE0
atcommand ATL0
atcommand ATI ELM327
atcommand ATH1
atcommand ATR1
atcommand ATS1

atcommand ATSH7DF
send 0904
readdata
send 0906
readdata
send 090A
readdata
atcommand ATSH7F1
send 2101
readdata

while true
do
  atcommand ATSH7DF
  send 2101
  readdata
  send 2102
  readdata
  send 2103
  readdata
  send 2104
  readdata
  send 2105
  readdata
  atcommand ATSH7D5
  send 2101
  readdata
  sleep 1
done
