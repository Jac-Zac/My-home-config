#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then







    xrdb -merge $sysresources

fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then







    xrdb -merge "$userresources"

fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi


# Keyboard Layout
setxkbmap us &

# Compositor
compton --config /home/jaczac/.config/compton/compton.conf -f &

# wallpaper
dyn-wall-rs -d wallpaper/24h &

# dwm status bar  
/home/jaczac/desktop/suckless/dwm-bar/dwm_bar.sh &

# start Bluetooth Applet
bluetooth-applet &

# start network manager 
nm-applet &

# Start WM 
exec dwm
