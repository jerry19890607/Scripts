
PWD=$1
test="$(echo -n $PWD | base64)"

AUTH="-H \'authorization: basic $test\'"
echo $AUTH

curl -I -k -X GET -H "Content-Type: application/json" -H "Authorization: Basic $(test)" https://10.148.20.6/redfish/v1
#curl -I -k -X GET -H "Content-Type: application/json" -u ADMIN:ADMIN https://10.148.20.6/redfish/v1

echo ""
