# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=100:
PORT=/dev/rfcomm0

exec 0< $PORT
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
  echo "$*"
} > $PORT

function recv()
{
  REPLY=""
  local c
  while read -s -N 1 -t "${1:-1}" c
  do
    examine "$c"
    case "$c" in
      ""|"\r"|"\n")
        TIMESTAMP=$(date +%s.%N)
        return 0
        ;;
      *)
        REPLY="$REPLY$c"
        ;;
    esac
  done
  return 1
}
