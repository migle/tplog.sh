# !/bin/bash
# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=100:

# Read one basic CAN frame at a time. We expect the identifier (header) at the
# first field, followed by each of the octets in separate fields.
# Something like this: 7EA 22 B9 88 AC 39 68 05 C2
while read TS ID DB1 DB2 DB3 DB4 DB5 DB6 DB7 DB8 TRASH
do
  # For each identifier, we use a different array for buffering until we have
  # a complete ISO-TP packet. For 7EA, this array is called BUF7EA.
  BTS="BTS${ID}"
  BUF="BUF${ID}"
  LEN="LEN${ID}"
  SEQ="SEQ${ID}"
  IDX="IDX${ID}"
  ALL="BUF${ID}[@]"

  # The first byte in the CAN frame is the ISO-TP header, and its high order
  # nibble tells if this is single frame, first, continuation or flow frame.
  case "${DB1}" in
    0[0-9A-Fa-f])
      # This is a single CAN frame ISO-TP packet. Length is low order nibble.
      N=$((0x${DB1}))
      # We still use the buffer, to be careful about the number of bytes.
      unset "${BUF}"
      declare "${BTS}"="${TS}"
      declare -a "${BUF}"
      for ((i = 0, j = 2; i < N && j <= 8; ++i, ++j))
      do
        VAR="DB${j}"
        declare "${BUF}"[i]=${!VAR:??}
      done
      # Then we output the assembled TP packet and cleanup.
      echo "${!BTS}" "${ID}" "${!ALL}"
      unset "${BUF}"
      ;;

    1[0-9A-Fa-f])
      # This is the first frame and the length is split along three nibbles.
      N=$((((0x${DB1} - 0x10) << 8) | 0x${DB2}))
      # Pass this information on for the next frames.
      declare "${LEN}"=$N
      declare "${SEQ}"=0x21
      declare "${IDX}"=6
      # The first elements in the array are filled from the given data bytes.
      unset "${BUF}"
      declare "${BTS}"="${TS}"
      declare -a "${BUF}"
      for ((i = 0, j = 3; i < N && j <= 8; ++i, ++j))
      do
        VAR="DB${j}"
        declare "${BUF}"[i]=${!VAR:??}
      done
      # The rest of the array is filled with ??. This tells the length of the
      # packet and whether all bytes were received.
      for (( ; i < N; ++i))
      do
        declare "${BUF}"[i]=??
      done
      ;;

    2[0-9A-Fa-f])
      # This is a continuation frame the second nibble is sequence number.
      # Tricky, because sequence numbers only go from 0 to f used rotatively.
      N=${!LEN}
      D=$((0x${DB1} - ${!SEQ}))
      if ((D < -8 || ${!IDX} + 7*D < 0))
      then
        D=$((D + 16))
      fi
      declare "${SEQ}"=0x${DB1}
      declare "${IDX}"=$((${!IDX} + 7*D))
      # Fill what we can on the array.
      for ((i = ${!IDX}, j = 2; i < N && j <= 8; ++i, ++j))
      do
        VAR="DB${j}"
        declare "${BUF}"[i]=${!VAR:??}
      done
      # If this is the last frame, output the assembled TP packet and cleanup.
      if ((i == N))
      then
        echo "${!BTS}" "${ID}" "${!ALL}"
        unset "${BUF}"
      fi
      ;;

    3[0-9A-Fa-f])
      # This is a flow control frame and we couldn't care less.
      ;;

    *)
      ;;
  esac
done
