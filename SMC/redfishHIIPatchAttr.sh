#/bin/sh
CASE_NUMBER=$1

case $CASE_NUMBER in
1)
    echo  -e "\e[38;5;120mReset to Default\e[0m"
    curl -k -H "Content-Type: application/json" -X POST https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios/Actions/Bios.ResetBios -d {} | python -m json.tool

    sleep 3
    echo  -e ""
    echo  -e "\e[38;5;120mGET SD\e[0m"
    curl -k -H "Content-Type: application/json" -X GET https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios/SD | python -m json.tool

    sleep 3
    echo  -e ""
    echo  -e "\e[38;5;120mPATCH {"CSPML069#0343": "TCG_2"}\e[0m"
    curl -k -H "Content-Type: application/json" -X PATCH https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios \
    -d '{"Attributes":{"CSPML069#0343": "TCG_2"}}' | python -m json.tool

    #echo  -e "\e[38;5;120mPATCH {"CSPML069#0343": "TCG_1_2"}\e[0m"
    #curl -k -H "Content-Type: application/json" -X PATCH https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios \
    #-d '{"Attributes":{"CSPML069#0343": "TCG_1_2"}}' | python -m json.tool

    sleep 3
    echo  -e ""
    echo  -e "\e[38;5;120mPATCH {"COMMN0164#0339": "Enable", "COMMN021#033A": "Enabled"}\e[0m"
    curl -k -H "Content-Type: application/json" -X PATCH https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios \
    -d '{"Attributes":{"COMMN020#0339": "Enable", "COMMN021#033A": "Enabled"}}' | python -m json.tool

    sleep 3
    echo  -e ""
    echo  -e "\e[38;5;120mGET SD\e[0m"
    curl -k -H "Content-Type: application/json" -X GET https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios/SD | python -m json.tool
;;

2)
    echo  -e "\e[38;5;120mReset to Default\e[0m"
    curl -k -H "Content-Type: application/json" -X POST https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios/Actions/Bios.ResetBios -d {} | python -m json.tool

    sleep 3
    echo  -e ""
    echo  -e "\e[38;5;120mGET SD\e[0m"
    curl -k -H "Content-Type: application/json" -X GET https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios/SD | python -m json.tool

    sleep 3
    echo  -e ""
    echo  -e "\e[38;5;120mPATCH {"CSPML069#0343": "TCG_2"}\e[0m"
    curl -k -H "Content-Type: application/json" -X PATCH https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios \
    -d '{"Attributes":{"CSPML069#0343": "TCG_2"}}' | python -m json.tool

    #echo  -e "\e[38;5;120mPATCH {"CSPML069#0343": "TCG_1_2"}\e[0m"
    #curl -k -H "Content-Type: application/json" -X PATCH https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios \
    #-d '{"Attributes":{"CSPML069#0343": "TCG_1_2"}}' | python -m json.tool

    sleep 3
    echo  -e ""
    echo  -e "\e[38;5;120mPATCH {"COMMN020#0339": "Enable", "COMMN022#033B": "Disabled"}\e[0m"
    curl -k -H "Content-Type: application/json" -X PATCH https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios \
    -d '{"Attributes":{"COMMN020#0339": "Enable", "COMMN022#033B": "Disabled"}}' | python -m json.tool

    sleep 3
    echo  -e ""
    echo  -e "\e[38;5;120mGET SD\e[0m"
    curl -k -H "Content-Type: application/json" -X GET https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios/SD | python -m json.tool
;;

3)
    echo  -e "\e[38;5;120mReset to Default\e[0m"
    curl -k -H "Content-Type: application/json" -X POST https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios/Actions/Bios.ResetBios -d {} | python -m json.tool

    sleep 3
    echo  -e ""
    echo  -e "\e[38;5;120mGET SD\e[0m"
    curl -k -H "Content-Type: application/json" -X GET https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios/SD | python -m json.tool

    sleep 3
    echo  -e ""
    echo  -e "\e[38;5;120mPATCH {"COMMN020#0339": "Enable","COMMN024#033F": "TPM Clear","COMMN026#0340": "Disabled","COMMN027#0341": "Disabled","COMMN028#0342": "Disabled"}\e[0m"
    curl -k -H "Content-Type: application/json" -X PATCH https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios \
    -d '{"Attributes":{"COMMN020#0339": "Enable","COMMN024#033F": "TPM Clear","COMMN026#0340": "Disabled","COMMN027#0341": "Disabled","COMMN028#0342": "Disabled"}}' | python -m json.tool

    sleep 3
    echo  -e ""
    echo  -e "\e[38;5;120mGET SD\e[0m"
    curl -k -H "Content-Type: application/json" -X GET https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios/SD | python -m json.tool
;;

4)
    echo  -e "\e[38;5;120mReset to Default\e[0m"
    curl -k -H "Content-Type: application/json" -X POST https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios/Actions/Bios.ResetBios -d {} | python -m json.tool

    sleep 1
    echo  -e ""
    echo  -e "\e[38;5;120mGET SD\e[0m"
    curl -k -H "Content-Type: application/json" -X GET https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios/SD | python -m json.tool

    sleep 1
    echo  -e ""
    echo  -e "\e[38;5;120mPATCH {"COMMN02C#0002": "Enabled","COMMN02D#0003": "Yes, Next reset","COMMN02E#0004": "Erase Immediately","COMMN02F#0005": "Enabled","COMMN030#0006": 100,"COMMN031#0007": 50}\e[0m"
    curl -k -H "Content-Type: application/json" -X PATCH https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios \
    -d '{"Attributes":{"COMMN02C#0002": "Enabled","COMMN02D#0003": "Yes, Next reset","COMMN02E#0004": "Erase Immediately","COMMN02F#0005": "Enabled","COMMN030#0006": 100,"COMMN031#0007": 50}}' \
    | python -m json.tool

    sleep 1
    echo  -e ""
    echo  -e "\e[38;5;120mGET SD\e[0m"
    curl -k -H "Content-Type: application/json" -X GET https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios/SD | python -m json.tool
;;

5)
    echo  -e "\e[38;5;120mReset to Default\e[0m"
    curl -k -H "Content-Type: application/json" -X POST https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios/Actions/Bios.ResetBios -d {} | python -m json.tool

    sleep 1
    echo  -e ""
    echo  -e "\e[38;5;120mGET SD\e[0m"
    curl -k -H "Content-Type: application/json" -X GET https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios/SD | python -m json.tool

    sleep 1
    echo  -e ""
    echo  -e "\e[38;5;120mPATCH {"CSPML038#2748": "Enable", "CSPML063#03C6": "Enable"}\e[0m"
    curl -k -H "Content-Type: application/json" -X PATCH https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios \
    -d '{"Attributes":{"CSPML038#2748": "Enable", "CSPML063#03C6": "Enable"}}' \
    | python -m json.tool

    sleep 1
    echo  -e ""
    echo  -e "\e[38;5;120mGET SD\e[0m"
    curl -k -H "Content-Type: application/json" -X GET https://ADMIN:ADMIN@10.148.164.6/redfish/v1/Systems/1/Bios/SD | python -m json.tool
;;
esac
