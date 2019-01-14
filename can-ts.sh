# !/bin/bash
# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=100:

# Read one basic CAN frame at a time. We expect the identifier (header) and
# all remaining octets unseparated, like this: 7EA22B988AC396805C2.
while read
do
  echo "0.000000000 ${REPLY}"
done
