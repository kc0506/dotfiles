#!/bin/bash

DISPLAY_NUM=":3"

echo "正在清理舊的 VNC session..."
ps -ef | grep "Xvnc $DISPLAY_NUM" | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null
rm -f /tmp/.X${DISPLAY_NUM:1}-lock
rm -f /tmp/.X11-unix/X${DISPLAY_NUM:1}

echo "正在啟動 Xvnc..."
Xvnc $DISPLAY_NUM -geometry 1920x1080 -depth 24 -rfbauth ~/.config/tigervnc/passwd -localhost no &

sleep 2

export DISPLAY=$DISPLAY_NUM
export LIBGL_ALWAYS_SOFTWARE=1
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_CURRENT_DESKTOP=Ubuntu:GNOME
export XDG_SESSION_TYPE=x11

echo "嘗試啟動 GNOME Classic / Flashback (更適合 VNC)..."

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-launch gnome-session
