#!/bin/bash
# batocera-switch-mousemove.sh 
##################################################
# Script para mover o cursor do mouse para o canto inferior direito da tela
# Útil para esconder o cursor durante a emulação Switch no Batocera

# Obter resolução da tela atual
r=$(xrandr | grep "+" | awk '{print $1}' | tail -n1)
w=$(echo "$r" | cut -d "x" -f1)  # largura em pixels
h=$(echo "$r" | cut -d "x" -f2)  # altura em pixels

# Criar links simbólicos para as dependências personalizadas do Batocera-Switch
# Isso garante que o xdotool funcione corretamente com as bibliotecas fornecidas
ln -sf /userdata/system/switch/extra/batocera-switch-libxdo.so.3 /lib/libxdo.so.3
ln -sf /userdata/system/switch/extra/batocera-switch-xdotool /usr/bin/xdotool

# Mover o cursor do mouse para o canto inferior direito da tela
# Verifica se largura e altura são números válidos (resoluções típicas como 1920x1080)
if [[ "$w" =~ ^[1-9][0-9]{2,}$ ]] && [[ "$h" =~ ^[1-9][0-9]{2,}$ ]]; then
  xdotool mousemove --sync $w $h 2>/dev/null
else 
  # Caso não consiga detectar a resolução corretamente, move para o canto superior esquerdo (0,0)
  xdotool mousemove --sync 0 0 2>/dev/null
fi