#!/bin/bash
#typedef enum {
#    TYPE_BOARD_PART_NUMBER      = 0X00,
#    TYPE_SERIAL_NUMBER          = 0X02,
#    TYPE_MARKETING_NAME         = 0X03,
#    TYPE_GPU_PART_NUMBER        = 0X04,
#    TYPE_BUILD_DATE             = 0X07,
#    TYPE_FW_VERSION             = 0X08,
#    TYPE_DEVICE_ID              = 0X0A,
#    TYPE_VENDOR_ID              = 0X0B,
#} GPUInfoType;
TYPE=0x0B

# X 7 6 5 | 4 3 2 1  | slot Number

# 7 6 5 4 | 3 2 1 0  | bit
# 8 4 2 1 | 8 4 2 1  |
#             1      | current
MUX_CH=0x04

IP="-H 10.138.160.45"

#SDA3: 0x02 * 2 + 1
I2C_ADDR=0x05

MUX_ADDR=0xE2
# NVIDIA:   98 9A 9C 9E
# AMD:      82
#=============================================
USER_INFO="-U ADMIN -P ADMIN"
RAW_DATA="raw 0x06 0x52"

IPMI="ipmitool $IP $USER_INFO"
#stop polling
#echo $IPMI raw 0x30 0x70 0xdf
#sleep 2

READ_LEN=0x01
# set MUX ch
echo "# "${IPMI} ${RAW_DATA} ${I2C_ADDR} ${MUX_ADDR} ${READ_LEN} ${MUX_CH}
${IPMI} ${RAW_DATA} ${I2C_ADDR} ${MUX_ADDR} ${READ_LEN} ${MUX_CH}
sleep 0.5
echo "# "${IPMI} ${RAW_DATA} ${I2C_ADDR} ${MUX_ADDR} ${READ_LEN}
${IPMI} ${RAW_DATA} ${I2C_ADDR} ${MUX_ADDR} ${READ_LEN}

#0xAC
SWITCH_ADDR=0xAC
READ_LEN=0x00
WRITE_DATA="0x10 0x12 0x01"
echo "# "${IPMI} ${RAW_DATA} ${I2C_ADDR} ${SWITCH_ADDR} ${READ_LEN} ${WRITE_DATA}
${IPMI} ${RAW_DATA} ${I2C_ADDR} ${SWITCH_ADDR} ${READ_LEN} ${WRITE_DATA}

GPU_ADDR=0x98
READ_LEN=0x00
WRITE_DATA="0x01 0x04 0x0F 0x01 0x66 0x5A"
echo "# "${IPMI} ${RAW_DATA} ${I2C_ADDR} ${GPU_ADDR} ${READ_LEN} ${WRITE_DATA}
${IPMI} ${RAW_DATA} ${I2C_ADDR} ${GPU_ADDR} ${READ_LEN} ${WRITE_DATA}


WRITE_DATA="0x03 0x83"
READ_LEN=0x05
echo "# "${IPMI} ${RAW_DATA} ${I2C_ADDR} ${GPU_ADDR} ${READ_LEN} ${WRITE_DATA}
${IPMI} ${RAW_DATA} ${I2C_ADDR} ${GPU_ADDR} ${READ_LEN} ${WRITE_DATA}

GPU_ADDR=$SWITCH_ADDR
CMD_CMD=0x5C
CMD=0x05
CMD_V1=0x00
CMD_V2=0x80
#set cmd for vid
echo "## "${IPMI} ${RAW_DATA} ${I2C_ADDR} ${GPU_ADDR} ${READ_LEN} ${CMD_CMD} 0x04 ${CMD} ${TYPE} ${CMD_V1} ${CMD_V2}
${IPMI} ${RAW_DATA} ${I2C_ADDR} ${GPU_ADDR} ${READ_LEN} ${CMD_CMD} 0x04 ${CMD} ${TYPE} ${CMD_V1} ${CMD_V2}

#read cmd stat
#$IPMI ${RAW_DATA} ${I2C_ADDR} ${GPU_ADDR} ${READ_LEN} ${CMD_CMD}

READ_LEN=0x05
CMD_DATA=0x5D
echo "## "${IPMI} ${RAW_DATA} ${I2C_ADDR} ${GPU_ADDR} ${READ_LEN} ${CMD_DATA}
${IPMI} ${RAW_DATA} ${I2C_ADDR} ${GPU_ADDR} ${READ_LEN} ${CMD_DATA}

READ_LEN=0x00
WRITE_DATA="0x10 0x12 0x00"
echo "# "${IPMI} ${RAW_DATA} ${I2C_ADDR} ${SWITCH_ADDR} ${READ_LEN} ${WRITE_DATA}
${IPMI} ${RAW_DATA} ${I2C_ADDR} ${SWITCH_ADDR} ${READ_LEN} ${WRITE_DATA}

exit 0
