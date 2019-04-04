rm rom128.ima
rm tmpfile

dd if=S5BN31000.ima of=/home/jerry-quad/tmp/128rom/tmpfile
sleep 1
dd if=S5BN31000.ima of=/home/jerry-quad/tmp/128rom/tmpfile seek=126976
sleep 1
dd if=tmpfile of=rom128.ima
sleep 1

#cp rom128.ima /home/shinyo/share/401755/rom401755.ima
