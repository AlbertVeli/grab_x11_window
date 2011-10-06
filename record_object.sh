#!/bin/sh

# ffmpeg script to record part of the desktop
# with ultimate codec flags.
#
# No Copyright!
#
# Albert Veli 2011

# TODO: Ask if user wants to recond sound.
#       If so, add -f alsa -ac 2 -i hw:0,0 -acodec pcm_s16le
#       to ffmpeg flags.

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

txt=`xwininfo`

corner=`echo $txt | sed 's/^.*Corners://' | awk '{print $1}' | sed 's/\(+[0-9]*\)+/\1,/'`

width=`echo $txt | sed 's/^.*Width://' | awk '{print $1}'`
height=`echo $txt | sed 's/^.*Height://' | awk '{print $1}'`

read -p "Window is ${width}x${height}, continue (y/n)? "
[ "$REPLY" == "y" ] || exit 1


# ffmpeg may or may not work with the x11grab option, it depends on the platform and compile time flags
ffmpeg -f x11grab -r 25 -s ${width}x${height} -i :0.0${corner} -an -vcodec libx264 -vpre lossless_ultrafast -threads 0 output.mkv
