# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=100:

stty sane -echo > /dev/stderr

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
  echo "$@"
}

function recv()
{
  read -s -t "${1:-1}" || return 1
  examine "$REPLY"
  return 0
}
