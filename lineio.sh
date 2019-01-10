# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=100:

function cerr()
{
  echo "$@"
} > /dev/stderr

function examine()
{
    echo -n "RECV: "
    echo -ne "$@" | od -An -tx1
} > /dev/stderr

function send()
{
  echo "$*"
}

function recv()
{
  read -rs -n 80 -t "${1:-1}" || return 1
  examine "$REPLY"
  if [[ "$REPLY" =~ ">*" ]]
  then
    REPLY="${REPLY#>}"
  fi
  return 0
}