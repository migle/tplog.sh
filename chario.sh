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
  REPLY=""
  local c
  while read -rs -N 1 -t "${1:-1}" c
  do
    examine "$c"
    case "$c" in
      ""|"\r"|"\n")
        return 0
        ;;
      ">")
        if [[ "${#REPLY}" != 0 ]]
        then
          REPLY="$REPLY$c"
        fi
        ;;
      *)
        REPLY="$REPLY$c"
        ;;
    esac
  done
  return 1
}
