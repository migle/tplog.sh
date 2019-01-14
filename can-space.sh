# !/bin/bash
# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=100:

# Read one basic CAN frame at a time. We expect the identifier (header) and
# all remaining octets unseparated, like this: 7EA22B988AC396805C2.
while read
do
  echo -n "${REPLY:0:3}"
  for ((i = 0; i < 8; ++i))
  do
    j=$((3 + i * 2))
    echo -n " ${REPLY:j:2}"
  done
  echo ""
done
