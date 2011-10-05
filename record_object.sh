#!/bin/sh

if ! which xwininfo >/dev/null; then
    echo "install xwininfo first"
fi

if ! which ffmpeg >/dev/null; then
    echo "install ffmpeg first"
fi

txt=`xwininfo`

corner=`echo $txt | sed 's/^.*Corners://' | awk '{print $1}' | sed 's/\(+[0-9]*\)+/\1,/'`

width=`echo $txt | sed 's/^.*Width://' | awk '{print $1}'`
height=`echo $txt | sed 's/^.*Height://' | awk '{print $1}'`

read -p "Window is ${width}x${height}, continue (y/n)? "
[ "$REPLY" == "y" ] || exit 1

ffmpeg -f x11grab -r 25 -s ${width}x${height} -i :0.0${corner} -an -vcodec libx264 -vpre lossless_ultrafast -threads 0 output.mkv
