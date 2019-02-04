# !/bin/bash
# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=0:

declare -A BECM
declare -a CELL
declare -A VMCU

testhex()
{
  local arg
  for arg in "$@"
  do
    [[ $arg =~ [0-9A-F]+ ]] || return 1
  done
  return 0
}

Signed()
{
  if ((0x$1 < 128))
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
  if [[ ${#BECM[*]} != 0 ]]
  then
    if [[ "${!BECM[*]}" != "${BECMH}" ]]
    then
      BECMH="${!BECM[*]}"
      printf "BECM,Timestamp,Device Time"
      for key in "${!BECM[@]}"
      do
        printf ",${key}"
      done
      echo ""
    fi
    printf "BECM,$1,$(date --date="@$1" "+%F %T")"
    for value in "${BECM[@]}"
    do
      printf ",${value}"
    done
    printf "\n"
  fi
}

ShowCELL()
{
  local key value
  if [[ ${#CELL[*]} != 0 ]]
  then
    if [[ "${!CELL[*]}" != "${CELLH}" ]]
    then
      CELLH="${!CELL[*]}"
      printf "CELL,Timestamp,Device Time"
      for key in "${!CELL[@]}"
      do
        printf ",000_Cell Voltage %02d" ${key}
      done
      echo ""
    fi
    printf "CELL,$1,$(date --date="@$1" "+%F %T")"
    for value in "${CELL[@]}"
    do
      printf ",${value}"
    done
    printf "\n"
  fi
}

ShowVMCU()
{
  local key value
  if [[ ${#VMCU[*]} != 0 ]]
  then
    if [[ "${!VMCU[*]}" != "${VMCUH}" ]]
    then
      VMCUH="${!VMCU[*]}"
      printf "VMCU,Timestamp,Device Time"
      for key in "${!VMCU[@]}"
      do
        printf ",${key}"
      done
      echo ""
    fi
    printf "VMCU,$1,$(date --date="@$1" "+%F %T")"
    for value in "${VMCU[@]}"
    do
      printf ",${value}"
    done
    printf "\n"
  fi
}

# Read one OBD-II packet at a time.
while read TS ID MODE PID A B C D E F G H I J K L M N O P Q R S T U V W X Y Z \
  AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ \
  BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ TRASH
do
  case "${ID}-${MODE}${PID}" in
    # BECM - Battery Energy Control Module
    7E4-2101|7EC-6101)
      BECM["000_State of Charge BMS"]=$(testhex $E && echo $((0x$E)) \* 0.5 | bc -q)
      BECM["000_Available Charge Power"]=$(testhex $F $G && echo $((0x$F<<8|0x$G)) \* 0.01 | bc -q)
      BECM["000_Available Discharge Power"]=$(testhex $H $I && echo $((0x$H<<8|0x$I)) \* 0.01 | bc -q)
      BECM["000_BMS Main Relay"]=$(testhex $J && echo $(Bit $J 0))
      BECM["000_Normal Charge Port"]=$(testhex $J && echo $(Bit $J 5))
      BECM["000_Rapid Charge Port"]=$(testhex $J && echo $(Bit $J 6))
      BECM["000_HV_Charging"]=$(testhex $J && echo $(Bit $J 7))
      BECM["000_Battery Current"]=$(testhex $K $L && echo $(($(Signed $K)<<8|0x$L)) \* 0.1 | bc -q)
      BECM["000_Battery DC Voltage"]=$(testhex $M $N && echo $((0x$M<<8|0x$N)) \* 0.1 | bc -q)
      BECM["000_Battery Max Temperature"]=$(testhex $O && echo $(Signed $O))
      BECM["000_Battery Min Temperature"]=$(testhex $P && echo $(Signed $P))
      BECM["000_Battery Module 01 Temperature"]=$(testhex $Q && echo $(Signed $Q))
      BECM["000_Battery Module 02 Temperature"]=$(testhex $R && echo $(Signed $R))
      BECM["000_Battery Module 03 Temperature"]=$(testhex $S && echo $(Signed $S))
      BECM["000_Battery Module 04 Temperature"]=$(testhex $T && echo $(Signed $T))
      BECM["000_Battery Module 05 Temperature"]=$(testhex $U && echo $(Signed $U))
      BECM["000_Battery Inlet Temperature"]=$(testhex $W && echo $(Signed $W))
      BECM["000_Maximum Cell Voltage"]=$(testhex $X && echo $((0x$X)) \* 0.02 | bc -q)
      BECM["000_Maximum Cell Voltage No."]=$(testhex $Y && echo $((0x$Y)))
      BECM["000_Minimum Cell Voltage"]=$(testhex $Z && echo $((0x$Z)) \* 0.02 | bc -q)
      BECM["000_Minimum Cell Voltage No."]=$(testhex $AA && echo $((0x$AA)))
      BECM["000_Battery Fan Status"]=$(testhex $AB && echo $((0x$AB)))
      BECM["000_Battery Fan Feedback"]=$(testhex $AC && echo $((0x$AC)))
      BECM["000_Auxillary Battery Voltage"]=$(testhex $AD && echo $((0x$AD)) \* 0.1 | bc -q)
      BECM["000_Cumulative Charge Current"]=$(testhex $AE $AF $AG $AH && echo $((0x$AE<<24|0x$AF<<16|0x$AG<<8|0x$AH)) \* 0.1 | bc -q)
      BECM["000_Cumulative Discharge Current"]=$(testhex $AI $AJ $AK $AL && echo $((0x$AI<<24|0x$AJ<<16|0x$AK<<8|0x$AL)) \* 0.1 | bc -q)
      BECM["000_Cumulative Energy Charged"]=$(testhex $AM $AN $AO $AP && echo $((0x$AM<<24|0x$AN<<16|0x$AO<<8|0x$AP)) \* 0.1 | bc -q)
      BECM["000_Cumulative Energy Discharged"]=$(testhex $AQ $AR $AS $AT && echo $((0x$AQ<<24|0x$AR<<16|0x$AS<<8|0x$AT)) \* 0.1 | bc -q)
      BECM["000_Operating Seconds"]=$(testhex $AU $AV $AW $AX && echo $((0x$AU<<24|0x$AV<<16|0x$AW<<8|0x$AX)))
      BECM["000_BMS Ignition"]=$(testhex $AY && echo $(Bit $AY 2))
      BECM["000_Inverter Capacitor Voltage"]=$(testhex $AZ $BA && echo $((0x$AZ<<8|0x$BA)))
      BECM["000_Drive Motor Speed 1"]=$(testhex $BB $BC && echo $(($(Signed $BB)<<8|0x$BC)))
      BECM["000_Drive Motor Speed 2"]=$(testhex $BD $BE && echo $(($(Signed $BD)<<8|0x$BE)))
      BECM["000_Isolation Resistance"]=$(testhex $BF $BG && echo $((0x$BF<<8|0x$BG)))
      ;;
    7E4-2105|7EC-6105)
      # bytes E to I (5) always 0
      BECM["000_Battery Module 06 Temperature"]=$(testhex $J && echo $(Signed $J))
      BECM["000_Battery Module 07 Temperature"]=$(testhex $K && echo $(Signed $K))
      BECM["000_Battery Module 08 Temperature"]=$(testhex $L && echo $(Signed $L))
      BECM["000_Battery Module 09 Temperature"]=$(testhex $M && echo $(Signed $M))
      BECM["000_Battery Module 10 Temperature"]=$(testhex $N && echo $(Signed $N))
      BECM["000_Battery Module 11 Temperature"]=$(testhex $O && echo $(Signed $O))
      BECM["000_Battery Module 12 Temperature"]=$(testhex $P && echo $(Signed $P))
      # bytes Q to T (4) similar to Max POWER / Max REGEN
      BECM["000_Battery Cell Voltage Deviation"]=$(testhex $U && echo $((0x$U)) \* 0.02 | bc -q)
      # byte V always 1?
      BECM["000_Airbag H/wire Duty"]=$(testhex $W && echo $((0x$W)))
      BECM["000_Battery Heater 1 Temperature"]=$(testhex $X && echo $(Signed $X))
      BECM["000_Battery Heater 2 Temperature"]=$(testhex $Y && echo $(Signed $Y))
      BECM["000_State of Health"]=$(testhex $Z $AA && echo $((0x$Z<<8|0x$AA)) \* 0.1 | bc -q)
      BECM["000_Maximum Deterioration Cell No."]=$(testhex $AB && echo $((0x$AB)))
      BECM["000_Minimum Deterioration"]=$(testhex $AC $AD && echo $((0x$AC<<8|0x$AD)) \* 0.1 | bc -q)
      BECM["000_Minimum Deterioration Cell No."]=$(testhex $AE && echo $((0x$AE)))
      BECM["000_State of Charge Display"]=$(testhex $AF && echo $((0x$AF)) \* 0.5 | bc -q)
      # byte AG always 0
      # byte AH 29/31
      # bytes AI to AQ (9) always 0
      ShowBECM $TS
      ;;

    7E4-2102|7EC-6102)
      CELL[1]=$(testhex $E && echo $((0x$E)) \* 0.02 | bc -q)
      CELL[2]=$(testhex $F && echo $((0x$F)) \* 0.02 | bc -q)
      CELL[3]=$(testhex $G && echo $((0x$G)) \* 0.02 | bc -q)
      CELL[4]=$(testhex $H && echo $((0x$H)) \* 0.02 | bc -q)
      CELL[5]=$(testhex $I && echo $((0x$I)) \* 0.02 | bc -q)
      CELL[6]=$(testhex $J && echo $((0x$J)) \* 0.02 | bc -q)
      CELL[7]=$(testhex $K && echo $((0x$K)) \* 0.02 | bc -q)
      CELL[8]=$(testhex $L && echo $((0x$L)) \* 0.02 | bc -q)
      CELL[9]=$(testhex $M && echo $((0x$M)) \* 0.02 | bc -q)
      CELL[10]=$(testhex $N && echo $((0x$N)) \* 0.02 | bc -q)
      CELL[11]=$(testhex $O && echo $((0x$O)) \* 0.02 | bc -q)
      CELL[12]=$(testhex $P && echo $((0x$P)) \* 0.02 | bc -q)
      CELL[13]=$(testhex $Q && echo $((0x$Q)) \* 0.02 | bc -q)
      CELL[14]=$(testhex $R && echo $((0x$R)) \* 0.02 | bc -q)
      CELL[15]=$(testhex $S && echo $((0x$S)) \* 0.02 | bc -q)
      CELL[16]=$(testhex $T && echo $((0x$T)) \* 0.02 | bc -q)
      CELL[17]=$(testhex $U && echo $((0x$U)) \* 0.02 | bc -q)
      CELL[18]=$(testhex $V && echo $((0x$V)) \* 0.02 | bc -q)
      CELL[19]=$(testhex $W && echo $((0x$W)) \* 0.02 | bc -q)
      CELL[20]=$(testhex $X && echo $((0x$X)) \* 0.02 | bc -q)
      CELL[21]=$(testhex $Y && echo $((0x$Y)) \* 0.02 | bc -q)
      CELL[22]=$(testhex $Z && echo $((0x$Z)) \* 0.02 | bc -q)
      CELL[23]=$(testhex $AA && echo $((0x$AA)) \* 0.02 | bc -q)
      CELL[24]=$(testhex $AB && echo $((0x$AB)) \* 0.02 | bc -q)
      CELL[25]=$(testhex $AC && echo $((0x$AC)) \* 0.02 | bc -q)
      CELL[26]=$(testhex $AD && echo $((0x$AD)) \* 0.02 | bc -q)
      CELL[27]=$(testhex $AE && echo $((0x$AE)) \* 0.02 | bc -q)
      CELL[28]=$(testhex $AF && echo $((0x$AF)) \* 0.02 | bc -q)
      CELL[29]=$(testhex $AG && echo $((0x$AG)) \* 0.02 | bc -q)
      CELL[30]=$(testhex $AH && echo $((0x$AH)) \* 0.02 | bc -q)
      CELL[31]=$(testhex $AI && echo $((0x$AI)) \* 0.02 | bc -q)
      CELL[32]=$(testhex $AJ && echo $((0x$AJ)) \* 0.02 | bc -q)
      ;;
    7E4-2103|7EC-6103)
      CELL[33]=$(testhex $E && echo $((0x$E)) \* 0.02 | bc -q)
      CELL[34]=$(testhex $F && echo $((0x$F)) \* 0.02 | bc -q)
      CELL[35]=$(testhex $G && echo $((0x$G)) \* 0.02 | bc -q)
      CELL[36]=$(testhex $H && echo $((0x$H)) \* 0.02 | bc -q)
      CELL[37]=$(testhex $I && echo $((0x$I)) \* 0.02 | bc -q)
      CELL[38]=$(testhex $J && echo $((0x$J)) \* 0.02 | bc -q)
      CELL[39]=$(testhex $K && echo $((0x$K)) \* 0.02 | bc -q)
      CELL[40]=$(testhex $L && echo $((0x$L)) \* 0.02 | bc -q)
      CELL[41]=$(testhex $M && echo $((0x$M)) \* 0.02 | bc -q)
      CELL[42]=$(testhex $N && echo $((0x$N)) \* 0.02 | bc -q)
      CELL[43]=$(testhex $O && echo $((0x$O)) \* 0.02 | bc -q)
      CELL[44]=$(testhex $P && echo $((0x$P)) \* 0.02 | bc -q)
      CELL[45]=$(testhex $Q && echo $((0x$Q)) \* 0.02 | bc -q)
      CELL[46]=$(testhex $R && echo $((0x$R)) \* 0.02 | bc -q)
      CELL[47]=$(testhex $S && echo $((0x$S)) \* 0.02 | bc -q)
      CELL[48]=$(testhex $T && echo $((0x$T)) \* 0.02 | bc -q)
      CELL[49]=$(testhex $U && echo $((0x$U)) \* 0.02 | bc -q)
      CELL[50]=$(testhex $V && echo $((0x$V)) \* 0.02 | bc -q)
      CELL[51]=$(testhex $W && echo $((0x$W)) \* 0.02 | bc -q)
      CELL[52]=$(testhex $X && echo $((0x$X)) \* 0.02 | bc -q)
      CELL[53]=$(testhex $Y && echo $((0x$Y)) \* 0.02 | bc -q)
      CELL[54]=$(testhex $Z && echo $((0x$Z)) \* 0.02 | bc -q)
      CELL[55]=$(testhex $AA && echo $((0x$AA)) \* 0.02 | bc -q)
      CELL[56]=$(testhex $AB && echo $((0x$AB)) \* 0.02 | bc -q)
      CELL[57]=$(testhex $AC && echo $((0x$AC)) \* 0.02 | bc -q)
      CELL[58]=$(testhex $AD && echo $((0x$AD)) \* 0.02 | bc -q)
      CELL[59]=$(testhex $AE && echo $((0x$AE)) \* 0.02 | bc -q)
      CELL[60]=$(testhex $AF && echo $((0x$AF)) \* 0.02 | bc -q)
      CELL[61]=$(testhex $AG && echo $((0x$AG)) \* 0.02 | bc -q)
      CELL[62]=$(testhex $AH && echo $((0x$AH)) \* 0.02 | bc -q)
      CELL[63]=$(testhex $AI && echo $((0x$AI)) \* 0.02 | bc -q)
      CELL[64]=$(testhex $AJ && echo $((0x$AJ)) \* 0.02 | bc -q)
      ;;
    7E4-2104|7EC-6104)
      CELL[65]=$(testhex $E && echo $((0x$E)) \* 0.02 | bc -q)
      CELL[66]=$(testhex $F && echo $((0x$F)) \* 0.02 | bc -q)
      CELL[67]=$(testhex $G && echo $((0x$G)) \* 0.02 | bc -q)
      CELL[68]=$(testhex $H && echo $((0x$H)) \* 0.02 | bc -q)
      CELL[69]=$(testhex $I && echo $((0x$I)) \* 0.02 | bc -q)
      CELL[70]=$(testhex $J && echo $((0x$J)) \* 0.02 | bc -q)
      CELL[71]=$(testhex $K && echo $((0x$K)) \* 0.02 | bc -q)
      CELL[72]=$(testhex $L && echo $((0x$L)) \* 0.02 | bc -q)
      CELL[73]=$(testhex $M && echo $((0x$M)) \* 0.02 | bc -q)
      CELL[74]=$(testhex $N && echo $((0x$N)) \* 0.02 | bc -q)
      CELL[75]=$(testhex $O && echo $((0x$O)) \* 0.02 | bc -q)
      CELL[76]=$(testhex $P && echo $((0x$P)) \* 0.02 | bc -q)
      CELL[77]=$(testhex $Q && echo $((0x$Q)) \* 0.02 | bc -q)
      CELL[78]=$(testhex $R && echo $((0x$R)) \* 0.02 | bc -q)
      CELL[79]=$(testhex $S && echo $((0x$S)) \* 0.02 | bc -q)
      CELL[80]=$(testhex $T && echo $((0x$T)) \* 0.02 | bc -q)
      CELL[81]=$(testhex $U && echo $((0x$U)) \* 0.02 | bc -q)
      CELL[82]=$(testhex $V && echo $((0x$V)) \* 0.02 | bc -q)
      CELL[83]=$(testhex $W && echo $((0x$W)) \* 0.02 | bc -q)
      CELL[84]=$(testhex $X && echo $((0x$X)) \* 0.02 | bc -q)
      CELL[85]=$(testhex $Y && echo $((0x$Y)) \* 0.02 | bc -q)
      CELL[86]=$(testhex $Z && echo $((0x$Z)) \* 0.02 | bc -q)
      CELL[87]=$(testhex $AA && echo $((0x$AA)) \* 0.02 | bc -q)
      CELL[88]=$(testhex $AB && echo $((0x$AB)) \* 0.02 | bc -q)
      CELL[89]=$(testhex $AC && echo $((0x$AC)) \* 0.02 | bc -q)
      CELL[90]=$(testhex $AD && echo $((0x$AD)) \* 0.02 | bc -q)
      CELL[91]=$(testhex $AE && echo $((0x$AE)) \* 0.02 | bc -q)
      CELL[92]=$(testhex $AF && echo $((0x$AF)) \* 0.02 | bc -q)
      CELL[93]=$(testhex $AG && echo $((0x$AG)) \* 0.02 | bc -q)
      CELL[94]=$(testhex $AH && echo $((0x$AH)) \* 0.02 | bc -q)
      CELL[95]=$(testhex $AI && echo $((0x$AI)) \* 0.02 | bc -q)
      CELL[96]=$(testhex $AJ && echo $((0x$AJ)) \* 0.02 | bc -q)
      ShowCELL $TS
      ;;

    # VMCU - Vehicle Main Control Unit
    7E2-2101|7EA-6101)
      # bytes A to E (5) always FF E0 00 00 00 09
      VMCU["003_VMCU P"]=$(testhex $F && echo $(Bit $F 0))
      VMCU["003_VMCU R"]=$(testhex $F && echo $(Bit $F 1))
      VMCU["003_VMCU N"]=$(testhex $F && echo $(Bit $F 2))
      VMCU["003_VMCU D"]=$(testhex $F && echo $(Bit $F 3))
      VMCU["003_VMCU Brake related"]=$(testhex $G && echo $((0x$G)))
      VMCU["003_VMCU Brake lamp"]=$(testhex $G && echo $(Bit $G 0))
      VMCU["003_VMCU Brakes On"]=$(testhex $G && echo $((1-$(Bit $G 1))))
      # bytes H to K (4) unknown (two 16-bit numbers)
      VMCU["003_VMCU Accel Pedal Related"]=$(testhex $L && echo $((0x$L)))
      VMCU["003_VMCU Accel Pedal Depth"]=$(testhex $M && echo $((0x$M)) \* 0.5 | bc -q)
      VMCU["003_VMCU Real Vehicle Speed"]=$(testhex $N $O && echo $(($(Signed $O)<<8|0x$N)) \* 0.01 | bc -q)
      # bytes P to T (5) unknown
      ;;
    7E2-2102|7EA-6102)
      # bytes A to D (4) always FF 80 00 00
      VMCU["003_VMCU Motor Actual Speed RPM"]=$(testhex $E $F && echo $(($(Signed $F)<<8|0x$E)))
      # bytes G to I (4) always 00
      # bytes J to U unknown
      ShowVMCU $TS
      ;;

    7E3-2101|7EB-6101)
      ;;
    7E3-2102|7EB-6102)
      ;;
    7E3-2103|7EB-6103)
      ;;

    # BCCM - Battery Charge Control Module
    7E5-2101|7ED-6101)
      BCCM[""]
      ;;
    7E5-2102|7ED-6102)
      ;;

    7D5-2101|7DD-6101)
      ;;
  esac
done
