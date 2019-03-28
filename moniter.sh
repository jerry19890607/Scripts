case $1 in
1)
xrandr --output VGA-1 --mode 800x600
;;
2)
xrandr --output VGA-1 --mode 1024x768
;;
3)
xrandr --output VGA-1 --mode 640x480
;;
4)
while [ 1 ] ;do for i in {1..3};do ./moniter.sh $i ;sleep 5;done;done
;;
esac
