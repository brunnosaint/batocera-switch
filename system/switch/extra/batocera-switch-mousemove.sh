#!/bin/bash
# batocera-switch-mousemove.sh 
##################################################

# obter resolução da tela 
  r=$(xrandr | grep "+" | awk '{print $1}' | tail -n1)
  w=$(echo "$r" | cut -d "x" -f1)
  h=$(echo "$r" | cut -d "x" -f2)

# preparar dependências 
  ln -sf /userdata/system/switch/extra/batocera-switch-libxdo.so.3 /lib/libxdo.so.3
  ln -sf /userdata/system/switch/extra/batocera-switch-xdotool /usr/bin/xdotool
 
# mover cursor do mouse para o canto inferior direito
if [[ "$w" =~ ^[1-9][0-9]{2,}$ ]] && [[ "$h" =~ ^[1-9][0-9]{2,}$ ]]; then
  xdotool mousemove --sync $w $h 2>/dev/null
else 
  xdotool mousemove --sync 0 0 2>/dev/null
fi