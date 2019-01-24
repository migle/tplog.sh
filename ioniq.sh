# !/bin/bash
# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=100:

# Read one OBD-II packet at a time.
while read TS ID MODE PID A B C D E F G H I J K L M N O P Q R S T U V W X Y Z \
  AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ \
  BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ TRASH
do
  case "${ID}-${MODE}${PID}" in
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

    # BMS data.
    7E4-2101|7EC-6101)
      # FF FF FF FF 88 26 48 26 48 03 FF 73 0E 52 10 0F 0F 10 0F 10 10 00 10 BF 24 BE 01 00 00 91 00 03 6A B1 00 03 69 AA 00 01 3B 1D 00 01 32 29 00 A3 93 44 0D 01 6E 07 08 07 08 03 E8
      # A  B  C  D  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  V  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  . 
      BMSAux=$((AD * 0.1))
      BMSMaxRegen=$((((F<<8) + G)*0.01))
      BMSMaxPower=$((((H<<8) + I)*0.01))
      BMSA=$((((K<<8) + L)*0.1))
      BMSDCV=$((((M<<8) + N)*0.1))
      BMSCCC=$((((AE<<24)+(AF<<16)+(AG<<8)+AH)*0.1))
      BMSCDC=$((((AI<<24)+(AJ<<16)+(AK<<8)+AL)*0.1))
      BMSCEC=$((((AM<<24)+(AN<<16)+(AO<<8)+AP)*0.1))
      BMSCED=$((((AQ<<24)+(AR<<16)+(AS<<8)+AT)*0.1))
      BMSMotor1=$(((BB<<8)+BC))
      BMSMotor2=$(((BD<<8)+BE))
      BMSICV=$(((AZ<<8) + BA))
      BMSIR=$(((BF<<8) + BG)
      BMSMaxV=$((X*0.02))
      BMSMaxVN=$((Y))
      BMSMinV=$((Z*0.02))
      BMSMinVN=$((AA))
      BMSOpTime=$(((AU<<24)+(AV<<16)+(AW<<8)+AX))
      BMSSoB=$((E*0.5))
      ;;
    7E4-2102|7EC-6102)
      ;;
    7E4-2103|7EC-6103)
      ;;
    7E4-2104|7EC-6104)
      ;;
    7E4-2105|7EC-6105)
      BMSVDiff=$((U*0.02))
      ;;

    7E5-2101|7ED-6101)
      ;;
    7E5-2102|7ED-6102)
      ;;

    7D5-2101|7DD-6101)
      ;;
  esac
done
