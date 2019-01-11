# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=100:

function can()
{
  local HDR IDX i j
  HDR=$1
  cerr CAN $HDR
  case $2 in
    10)
      LEN=$((0x$3))
      for ((i = 4, j = 0; i <= 9 && j < LEN; ++i, ++j))
      do
        cerr $j = ${!i}
      done
      ;;
    2[0-9A-F])
      IDX=$((6 + 7*(0x$2 - 0x21)))
      for ((i = 3, j = IDX; i <= 9 && j < LEN; ++i, ++j))
      do
        cerr $j = ${!i}
      done
      if [[ $j == $LEN ]]
      then
        cerr DONE $HDR
      fi
      ;;
  esac
}
