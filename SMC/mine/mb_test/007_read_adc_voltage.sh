#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

#VOL=$1
#SENSOR=$2
#
#V_L_NR=`echo "scale=3;$VOL * (1 - 0.208)" | bc`
#V_L_CT=`echo "scale=3;$VOL * (1 - 0.1875)" | bc`
#V_L_NC=`echo "scale=3;$VOL * (1 - 0.125)" | bc`
#V_H_NC=`echo "scale=3;$VOL * (1 + 0.125)" | bc`
#V_H_CT=`echo "scale=3;$VOL * (1 + 0.1875)" | bc`
#V_H_NR=`echo "scale=3;$VOL * (1 + 0.208)" | bc`

#printf "%.1f\n" $(echo "scale=2;$TOTAL/86400"|bc)
#echo $V_L_NR, $V_L_CT, $V_L_NC, $V_H_NC, $V_H_CT, $V_H_NR
#printf "%.2f\n" $V_H_NR

#ipmitool -H <IPAddr> -U ADMIN -P ADMIN -I lanplus raw 0x04 0x2d <SensorID>
CMD="0x04 0x2d"
SENSOR_ID=$1
echo ${IPMI} ${RAW} ${CMD} ${SENSOR_ID}
${IPMI} ${RAW} ${CMD} ${SENSOR_ID}
