while [ 1 ]
do
    curl -i -k -X GET -H "X-Auth-Token: unz1cn4ch99r8jzavgv7l8dxoyche9rt" "https://10.138.160.81/redfish/v1/Systems/1" >> /home/jerry/ssd/tmp/token/token 2>&1;
    sleep 2;
done;

