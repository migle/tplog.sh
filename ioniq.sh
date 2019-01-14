# !/bin/bash
# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=100:

# Read one OBD-II packet at a time.
while read TS ID MODE PID A B C D E F G H I J K L M N O P Q R S T U V W X Y Z \
  AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ TRASH
do
  case "${ID}-${MODE}${PID}" in
    7EA-0921)
      ;;
    7EA-6101)
      ;;
    7EA-6102)
      ;;

    7EB-6101)
      ;;
    7EB-6102)
      ;;
    7EB-6103)
      ;;

    7EC-6101)
      ;;
    7EC-6102)
      ;;
    7EC-6103)
      ;;
    7EC-6104)
      ;;
    7EC-6105)
      ;;

    7ED-6101)
      ;;
    7ED-6102)
      ;;

    7DD-*)
      ;;
    7EE-*)
      ;;
  esac
done
