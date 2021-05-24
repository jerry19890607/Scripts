
#test="Authorization: Basic $(echo -n ADMIN:ADMIN | base64)"
#sign="'"
#final="$(echo $sign$test$sign)"
#echo $final

#echo "curl -k -X GET -H "Content-Type: application/json" -H $final https://10.148.20.6/redfish/v1/Systems | python -m json.tool"
#curl -k -X GET -H "Content-Type: application/json" -H $final https://10.148.20.6/redfish/v1/Systems | python -m json.tool


NAME=ADMIN
PASSWORD=ADMIN

cred="$( echo -n $NAME:$PASSWORD | base64 )"
curl -k -X GET -H "Content-Type: application/json" -H "Authorization: Basic $cred" https://10.148.20.6/redfish/v1/Systems/1 | python -m json.tool


