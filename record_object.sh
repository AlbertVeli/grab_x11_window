#!/bin/sh

# ffmpeg script to record part of the desktop
# with ultimate codec flags.
#
# No Copyright!
#
# Albert Veli 2011


# Alsa device. Change this to use another
# sound card than the default 'hw:0,0'. You could even
# change it to 'pulse' to use pulseaudio instead.
alsadev='hw:0,0'

# Video codec for encoding. You might change this
# if your ffmpeg does not support libx264. But
# this setting gives best quality.
vcodec='-vcodec libx264 -preset ultrafast -qp 0'


if ! which xwininfo >/dev/null; then
    echo "install xwininfo first"
fi

if ! which ffmpeg >/dev/null; then
    echo "install ffmpeg first"
fi

x11grab=`ffmpeg -formats 2>/dev/null | grep -i x11grab`
[ "$x11grab" == "" ] && echo "Warning: your ffmpeg does not seem to support x11 grabbing, try compiling it yourself with appropriate flags"

x11grab=`ffmpeg -codecs 2>/dev/null | grep -i libx264`
[ "$x11grab" == "" ] && echo "Warning: your ffmpeg does not seem to support libx264, try compiling it yourself with appropriate flags (or edit the scipt and choose another codec)"

echo "Click on the window you want to record (or on the background to record everything)."
echo "When finished, quit recording by pressing q or Ctrl-C"

read -p "Record sound? "
if test "$REPLY" == "y"; then
    # Record sound using Alsa
    # (check rec volume in alsamixer if you get no sound)
    snd="-f alsa -ac 2 -i $alsadev -acodec pcm_s16le"
else
    # No sound
    snd='-an'
fi

# Get upper left corner, width and height using xwininfo.
txt=`xwininfo`
if test "$txt" == ""; then
    echo "Error getting window information."
    exit 1
fi
corner=`echo $txt | sed 's/^.*Corners://' | awk '{print $1}' | sed 's/\(+[0-9]*\)+/\1,/'`
width=`echo $txt | sed 's/^.*Width://' | awk '{print $1}'`
height=`echo $txt | sed 's/^.*Height://' | awk '{print $1}'`

read -p "Window is ${width}x${height}, continue (y/n)? "
[ "$REPLY" == "y" ] || exit 1

# Make sure width is divisible by 2
width=$((${width} - $((${width} % 2))))

# ffmpeg may or may not work with the x11grab option, it depends on the platform and compile time flags
CMD="ffmpeg -f x11grab -r 25 -s ${width}x${height} -i :0.0${corner} $snd $vcodec -threads 0 output.mkv"
exec $CMD
