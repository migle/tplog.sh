# !/bin/bash
# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=0:

declare -A BECM

testhex()
{
  local arg
  for arg in "$@"
  do
    [[ $arg =~ ^[0-9a-f]+$ ]] || return 1
  done
  return 0
  return 0
}

Signed()
{
  if ((0x$1 & 0x80 == 0))
  then
    echo $((0x$1))
  else
    echo -$((~0x$1+1&0xFF))
  fi
}

Bit()
{
  echo $((0x$1>>$2&1))
}

ShowBECM()
{
  local key value
  if [[ "${!BECM[*]}" != "${BECMH}" ]]
  then
    BECMH="${!BECM[*]}"
    echo -n "BECM,Timestamp,Device Time"
    for key in "${!BECM[@]}"
    do
      echo -n ",${key}"
    done
    echo ""
  fi
  echo -n "BECM,$1,$(date --date="@$1" "+%F %T")"
  for value in "${BECM[@]}"
  do
    echo -n ",${value}"
  done
  echo ""
}

# Read one OBD-II packet at a time.
while read TS ID MODE PID A B C D E F G H I J K L M N O P Q R S T U V W X Y Z \
  AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ \
  BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ TRASH
do
  case "${ID}-${MODE}${PID}" in
    # BECM
    7E4-2101|7EC-6101)
      BECM["000_State of Charge BMS"]=$(testhex $E && (echo $((0x$E)) \* 0.5 | bc -q) || echo)
      BECM["000_Available Charge Power"]=$(testhex $F $G && (echo $((0x$F<<8|0x$G)) \* 0.01 | bc -q) || echo)
      BECM["000_Available Discharge Power"]=$(testhex $H $I && (echo $((0x$H<<8|0x$I)) \* 0.01 | bc -q) || echo)
      BECM["000_BMS Main Relay"]=$(testhex $J && echo $(Bit $J 0) || echo)
      BECM["000_Normal Charge Port"]=$(testhex $J && echo $(Bit $J 5) || echo)
      BECM["000_Rapid Charge Port"]=$(testhex $J && echo $(Bit $J 6) || echo)
      BECM["000_HV_Charging"]=$(testhex $J && echo $(Bit $J 7) || echo)
      BECM["000_Battery Current"]=$(testhex $K $L && (echo $(($(Signed $K)<<8|0x$L)) \* 0.1 | bc -q) || echo)
      BECM["000_Battery DC Voltage"]=$(testhex $M $N && (echo $((0x$M<<8|0x$N)) \* 0.1 | bc -q) || echo)
      BECM["000_Battery Max Temperature"]=$(testhex $O && echo $(Signed $O) || echo)
      BECM["000_Battery Min Temperature"]=$(testhex $P && echo $(Signed $P) || echo)
      BECM["000_Battery Module 01 Temperature"]=$(testhex $Q && echo $(Signed $Q) || echo)
      BECM["000_Battery Module 02 Temperature"]=$(testhex $R && echo $(Signed $R) || echo)
      BECM["000_Battery Module 03 Temperature"]=$(testhex $S && echo $(Signed $S) || echo)
      BECM["000_Battery Module 04 Temperature"]=$(testhex $T && echo $(Signed $T) || echo)
      BECM["000_Battery Module 05 Temperature"]=$(testhex $U && echo $(Signed $U) || echo)
      BECM["000_Battery Inlet Temperature"]=$(testhex $W && echo $(Signed $W) || echo)
      BECM["000_Maximum Cell Voltage"]=$(testhex $X && (echo $((0x$X)) \* 0.02 | bc -q) || echo)
      BECM["000_Maximum Cell Voltage No."]=$(testhex $Y $ && echo $((0x$Y)) || echo)
      BECM["000_Minimum Cell Voltage"]=$(testhex $Z && (echo $((0x$Z)) \* 0.02 | bc -q) || echo)
      BECM["000_Minimum Cell Voltage No."]=$(testhex $AA $ && echo $((0x$AA)) || echo)
      BECM["000_Battery Fan Status"]=$(testhex $AB $ && echo $((0x$AB)) || echo)
      BECM["000_Battery Fan Feedback"]=$(testhex $AC && echo $((0x$AC)) || echo)
      BECM["000_Auxillary Battery Voltage"]=$(testhex $AD && (echo $((0x$AD)) \* 0.1 | bc -q) || echo)
      BECM["000_Cumulative Charge Current"]=$(testhex $AE $AF $AG $AH && (echo $((0x$AE<<24|0x$AF<<16|0x$AG<<8|0x$AH)) \* 0.1 | bc -q) || echo)
      BECM["000_Cumulative Discharge Current"]=$(testhex $AI $AJ $AK $AL && (echo $((0x$AI<<24|0x$AJ<<16|0x$AK<<8|0x$AL)) \* 0.1 | bc -q) || echo)
      BECM["000_Cumulative Energy Charged"]=$(testhex $AM $AN $AO $AP && (echo $((0x$AM<<24|0x$AN<<16|0x$AO<<8|0x$AP)) \* 0.1 | bc -q) || echo)
      BECM["000_Cumulative Energy Discharged"]=$(testhex $AQ $AR $AS $AT && (echo $((0x$AQ<<24|0x$AR<<16|0x$AS<<8|0x$AT)) \* 0.1 | bc -q) || echo)
      BECM["000_Operating Seconds"]=$(testhex $AU $AV $AW $AX && echo $((0x$AU<<24|0x$AV<<16|0x$AW<<8|0x$AX)) || echo)
      BECM["000_BMS Ignition"]=$(testhex $AY && echo $(Bit $AY 2) || echo)
      BECM["000_Inverter Capacitor Voltage"]=$(testhex $AZ $BA && echo $((0x$AZ<<8|0x$BA)) || echo)
      BECM["000_Drive Motor Speed 1"]=$(testhex $BB $BC && echo $(($(Signed $BB)<<8|0x$BC)) || echo)
      BECM["000_Drive Motor Speed 2"]=$(testhex $BD $BE && echo $(($(Signed $BD)<<8|0x$BE)) || echo)
      BECM["000_Isolation Resistance"]=$(testhex $BF $BG && echo $((0x$BF<<8|0x$BG)) || echo)
      ShowBECM $TS
      ;;

    7E4-2102|7EC-6102)
      #CELL[""]=$(testhex $X && (echo $((0x$X)) \* 0.02 | bc -q) || echo)
      ;;
    7E4-2103|7EC-6103)
      ;;
    7E4-2104|7EC-6104)
      ;;
    7E4-2105|7EC-6105)
      BECM["000_Battery Module 06 Temperature"]=$(testhex $J && echo $(Signed $J) || echo)
      BECM["000_Battery Module 07 Temperature"]=$(testhex $K && echo $(Signed $K) || echo)
      BECM["000_Battery Module 08 Temperature"]=$(testhex $L && echo $(Signed $L) || echo)
      BECM["000_Battery Module 09 Temperature"]=$(testhex $M && echo $(Signed $M) || echo)
      BECM["000_Battery Module 10 Temperature"]=$(testhex $N && echo $(Signed $N) || echo)
      BECM["000_Battery Module 11 Temperature"]=$(testhex $O && echo $(Signed $O) || echo)
      BECM["000_Battery Module 12 Temperature"]=$(testhex $P && echo $(Signed $P) || echo)

      BECM["000_Battery Cell Voltage Deviation"]=$(testhex $U && (echo $((0x$U)) \* 0.02 | bc -q) || echo)
      BECM["000_Airbag H/wire Duty"]=$(testhex $W && echo $((0x$W)) || echo)

      BECM["000_Battery Heater 1 Temperature"]=$(testhex $X && echo $(Signed $X) || echo)
      BECM["000_Battery Heater 2 Temperature"]=$(testhex $Y && echo $(Signed $Y) || echo)
      BECM["000_State of Health"]=$(testhex $Z $AA && (echo $((0x$Z<<8|0x$AA)) \* 0.1 | bc -q) || echo)
      BECM["000_Maximum Deterioration Cell No."]=$(testhex $AB && echo $((0x$AB)) || echo)
      BECM["000_Minimum Deterioration"]=$(testhex $AC $AD && (echo $((0x$AC<<8|0x$AD)) \* 0.1 | bc -q) || echo)
      BECM["000_Minimum Deterioration Cell No."]=$(testhex $AE && echo $((0x$AE)) || echo)
      BECM["000_State of Charge Display"]=$(testhex $AF && (echo $((0x$AF)) \* 0.5 | bc -q) || echo)
      ;;

    7E2-0921|7EA-0921)
      ;;
    7E2-2101|7EA-6101)
      ;;
    7E2-2102|7EA-6102)
      ;;

    7E3-2101|7EB-6101)
      ;;
    7E3-2102|7EB-6102)
      ;;
    7E3-2103|7EB-6103)
      ;;

    7E5-2101|7ED-6101)
      ;;
    7E5-2102|7ED-6102)
      ;;

    7D5-2101|7DD-6101)
      ;;
  esac
done
