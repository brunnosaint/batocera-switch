#!/usr/bin/env bash
################################################################################
# v3.3                ATUALIZADOR DE EMULADORES SWITCH PARA BATOCERA           #
#                   ----------------------------------------                   #
#                     > github.com/brunnosaint/batocera-switch                    #
#                        > https://discord.gg/SWBvBkmn9P                       #     
################################################################################
#  ---------------
#     CONFIGURAÇÕES 
#  ---------------
#
EMULATORS="YUZU YUZUEA RYUJINX RYUJINXLDN RYUJINXAVALONIA" 
#        |
#        padrão: "YUZU YUZUEA RYUJINX RYUJINXLDN RYUJINXAVALONIA"
#
#   EMULATORS="RYUJINX YUZU"  -->  atualizará apenas ryujinx e depois yuzu   
#   EMULATORS="YUZUEA"  -->  atualizará apenas yuzu early access     
#
################################################################################
#
MODE=DISPLAY 
#   | 
#   padrão: DISPLAY 
#
#   MODE=DISPLAY  -->  para ports; usa processo xterm em tela cheia para mostrar o atualizador  
#   MODE=CONSOLE  -->  para ssh/console/xterm; sem cores, sem exibição adicional  
#                
    ANIMATION=NO
#   reproduz animação de carregamento ao iniciar o atualizador    
#
################################################################################
#
UPDATES=UNLOCKED
#      | 
#      padrão: LOCKED
#       
#   UPDATES=LOCKED  -->  limita ryujinx à versão 1.1.382 para compatibilidade 
#   UPDATES=UNLOCKED  -->  baixa as versões mais recentes dos emuladores ryujinx 
#
#   *) use esta opção se quiser atualizar ryujinx para as versões mais recentes, 
#   e usar configuração manual de controle (você pode fazer isso no 
#   [[ menu f1 ]] --> ryujinx-avalonia   
#
#################################################################################
#
TEXT_SIZE=AUTO
#        |
#        padrão: AUTO
#
#   TEXT_SIZE=10  -->  usará tamanho de fonte personalizado, = 10  
# 
################################################################################
#
TEXT_COLOR=WHITE
THEME_COLOR=WHITE
THEME_COLOR_OK=WHITE
THEME_COLOR_YUZU=RED
THEME_COLOR_YUZUEA=RED
THEME_COLOR_RYUJINX=BLUE
THEME_COLOR_RYUJINXLDN=BLUE
THEME_COLOR_RYUJINXAVALONIA=BLUE
#
#   CORES DISPONÍVEIS:
#   |
#   WHITE,BLACK,RED,GREEN,BLUE,YELLOW,PURPLE,CYAN
#   DARKRED,DARKGREEN,DARKBLUE,DARKYELLOW,DARKPURPLE,DARKCYAN#
#
######################################################################
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@                @@@@@            @@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@                   @@@@@                @@@@@@@@@@@@@@@
# @@@@@@@@@@@     @@@@@@@@@@@@    @@@@@                  @@@@@@@@@@@@@
# @@@@@@@@@     @@@@@@@@@@@@@@    @@@@@                   @@@@@@@@@@@@
# @@@@@@@@@    @@@@@      @@@@    @@@@@                   @@@@@@@@@@@@
# @@@@@@@@@    @@@         @@@    @@@@@                   @@@@@@@@@@@@
# @@@@@@@@@    @@@@        @@@    @@@@@                   @@@@@@@@@@@@
# @@@@@@@@@    @@@@@@   %@@@@@    @@@@@                   @@@@@@@@@@@@
# @@@@@@@@@    @@@@@@@@@@@@@@@    @@@@@       @@@@        @@@@@@@@@@@@
# @@@@@@@@@    @@@@@@@@@@@@@@@    @@@@@     @@@@@@@@      @@@@@@@@@@@@
# @@@@@@@@@    @@@@@@@@@@@@@@@    @@@@@    @@@@@@@@@@     @@@@@@@@@@@@
# @@@@@@@@@    @@@@@@@@@@@@@@@    @@@@@     @@@@@@@@      @@@@@@@@@@@@
# @@@@@@@@@    @@@@@@@@@@@@@@@    @@@@@        @@         @@@@@@@@@@@@
# @@@@@@@@@    @@@@@@@@@@@@@@@    @@@@@                   @@@@@@@@@@@@
# @@@@@@@@@    @@@@@@@@@@@@@@@    @@@@@                   @@@@@@@@@@@@
# @@@@@@@@@    @@@@@@@@@@@@@@@    @@@@@                   @@@@@@@@@@@@
# @@@@@@@@@@     @@@@@@@@@@@@@    @@@@@                  @@@@@@@@@@@@@
# @@@@@@@@@@@@      @@@@@@@@@@    @@@@@                @@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@                 @@@@@             @@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#                > github.com/brunnosaint/batocera-switch               #
#                    > https://discord.gg/SWBvBkmn9P                 #
######################################################################
######################################################################
######################################################################
######################################################################
# --------------------------------------------------------------------
sysctl -w net.ipv6.conf.default.disable_ipv6=1 1>/dev/null 2>/dev/null
sysctl -w net.ipv6.conf.all.disable_ipv6=1 1>/dev/null 2>/dev/null
# --------------------------------------------------------------------
export DISPLAY=:0.0
# --------------------------------------------------------------------
cp $(which xterm) /tmp/batocera-switch-updater && chmod 777 /tmp/batocera-switch-updater
# --------------------------------------------------------------------
if [[ "$1" = "CONSOLE" ]] || [[ "$1" = "console" ]]; then 
MODE=CONSOLE
fi
function check-connection() {
# VERIFICAR CONEXÃO
net="on" ; net1="on" ; net2="on" ; net3="on"
case "$(curl -s --max-time 2 -I http://github.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23]) net1="on";;
  5) net1="off";;
  *) net1="off";;
esac 
ping -q -w 1 -c 1 github.com > /dev/null && net2="on" || net2="off"
wget -q --spider http://github.com && if [ $? -eq 0 ]; then net3="on"; else net3="off"; fi
if [[ "$net1" = "off" ]] && [[ "$net2" = "off" ]] && [[ "$net3" = "off" ]]; then net="off"; fi 
if [[ "$net1" = "on" ]] || [[ "$net2" = "on" ]] || [[ "$net3" = "on" ]]; then net="on"; fi 
##
if [[ "$net" = "off" ]]; then 
DISPLAY=:0.0 /tmp/batocera-switch-updater -fs 10 -maximized -fg black -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "echo -e \"\n \033[0;37m SEM CONEXÃO COM A INTERNET :( \033[0;30m \" & sleep 3" 2>/dev/null && exit 0 & exit 1 & exit 2
fi 
}
function check_internet() {
    # Verificar usando curl
    if curl -s --max-time 2 -I http://github.com | grep -q "HTTP/[12].[01] [23].."; then
        return 0
    fi 
    
    # Verificar usando ping
    if ping -q -w 1 -c 1 github.com > /dev/null; then
        return 0
    fi

    # Verificar usando wget
    if wget -q --spider http://github.com; then
        return 0
    fi

    # Se todos os métodos falharem, reportar sem conectividade
    return 1
}
# Verificar conexão com a internet
if check_internet; then
   net="on"
else 
   DISPLAY=:0.0 /tmp/batocera-switch-updater -fs 10 -maximized -fg black -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "echo -e \"\n \033[0;37m SEM CONEXÃO COM A INTERNET :( \033[0;30m \" & sleep 3" 2>/dev/null && exit 0 && exit 1 && exit 2   
fi
# --------------------------------------------------------------------
# limpar logs antigos: 
rm -rf /userdata/system/switch/extra/logs 2>/dev/null
mkdir -p /userdata/system/switch/logs 2>/dev/null
# --------------------------------------------------------------------
# limpar todos os atalhos antigos/quebrados/usuário na área de trabalho: 
rm -rf /userdata/system/switch/*.desktop 2>/dev/null
# --------------------------------------------------------------------
# PREPARAR ATALHOS PARA O MENU F1-APLICAÇÕES 
# --------------------------------------------------------------------
function generate-shortcut-launcher { 
# ESCALA PARA APPS F1, PADRÃO 128@1 
DPI=128
SCALE=1
Name=$1
name=$2
extra=/userdata/system/switch/extra
# --------------------------------------------------------------------
f=$extra/$Name.desktop
# --------------------------------------------------------------------
rm -rf "$f" 2>/dev/null
   echo "[Desktop Entry]" >> "$f"
   echo "Version=1.0" >> "$f"
      if [[ "$Name" = "yuzu" ]]; then 
         echo "Icon=/userdata/system/switch/extra/icon_yuzu.png" >> "$f"
         echo 'Exec=/userdata/system/switch/yuzu.AppImage' >> "$f" 
         fi
      if [[ "$Name" = "yuzuEA" ]]; then 
         echo "Icon=/userdata/system/switch/extra/icon_yuzu.png" >> "$f"
         echo 'Exec=/userdata/system/switch/yuzuEA.AppImage' >> "$f" 
         fi
      if [[ "$Name" = "Ryujinx" ]]; then 
         echo "Icon=/userdata/system/switch/extra/icon_ryujinx.png" >> "$f"
         echo 'Exec=/userdata/system/switch/Ryujinx.AppImage' >> "$f" 
         fi
      if [[ "$Name" = "Ryujinx-LDN" ]]; then 
         echo "Icon=/userdata/system/switch/extra/icon_ryujinx.png" >> "$f"
         echo 'Exec=/userdata/system/switch/Ryujinx-LDN.AppImage' >> "$f" 
         fi
      if [[ "$Name" = "Ryujinx-Avalonia" ]]; then 
         echo "Icon=/userdata/system/switch/extra/icon_ryujinx.png" >> "$f"
         echo 'Exec=/userdata/system/switch/Ryujinx-Avalonia.AppImage' >> "$f" 
         fi
      if [[ "$Name" = "switch-updater" ]]; then 
         echo "Icon=/userdata/system/switch/extra/icon_updater.png" >> "$f"
         echo 'Exec=/userdata/system/switch/extra/batocera-switch-desktopupdater.sh' >> "$f" 
         # também preparar atualizador de desktop 
         ####################################################################
            u=/userdata/system/switch/extra/batocera-switch-desktopupdater.sh
               rm "$u" 2>/dev/null
                  echo '#!/bin/bash' >> "$u"
                  echo "sed -i 's/^Icon=.*$/Icon=\/userdata\/system\/switch\/extra\/icon_loading.png/' /usr/share/applications/switch-updater.desktop 2>/dev/null" >> "$u"
                  echo "  rm /tmp/.batocera-switch-updater.sh 2>/dev/null" >> "$u"
                  echo "  wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O /tmp/.batocera-switch-updater.sh https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/batocera-switch-updater.sh" >> "$u"
                  ##echo "  curl -sSf https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/batocera-switch-updater.sh -o /tmp/.batocera-switch-updater.sh " >> "$u"
                  echo "  sed -i 's,unclutter-remote -h,unclutter-remote -s,g' /tmp/.batocera-switch-updater.sh" >> "$u"
                  echo "  dos2unix /tmp/.batocera-switch-updater.sh 2>/dev/null && chmod 777 /tmp/.batocera-switch-updater.sh 2>/dev/null" >> "$u"
                  echo "    bash /tmp/.batocera-switch-updater.sh" >> "$u"
                  echo "  rm /tmp/.batocera-switch-updater.sh 2>/dev/null" >> "$u"
                  echo "sed -i 's/^Icon=.*$/Icon=\/userdata\/system\/switch\/extra\/icon_updater.png/' /usr/share/applications/switch-updater.desktop 2>/dev/null" >> "$u"
                  echo "exit 0" >> "$u"
                     dos2unix "$u" 2>/dev/null && chmod a+x "$u" 2>/dev/null
         ####################################################################
         #/
         fi
   echo "Terminal=false" >> "$f"
   echo "Type=Application" >> "$f"
   echo "Categories=Game;batocera.linux;" >> "$f"
   ####
   if [[ "$Name" != "switch-updater" ]]; then 
      echo "Name=$name-config" >> "$f"
   else
      echo "Name=$name" >> "$f"
   fi 
   ####
      dos2unix "$f" 2>/dev/null
      chmod a+x "$f" 2>/dev/null
} 
# -----------------------------------------------------------------
#
# remover atalhos antigos da versão de ~/.local/share/applications 
rm /userdata/system/.local/share/applications/yuzu-config.desktop 2>/dev/null
rm /userdata/system/.local/share/applications/yuzuEA-config.desktop 2>/dev/null
rm /userdata/system/.local/share/applications/ryujinx-config.desktop 2>/dev/null
rm /userdata/system/.local/share/applications/ryujinxavalonia-config.desktop 2>/dev/null
rm /userdata/system/.local/share/applications/ryujinxldn-config.desktop 2>/dev/null
# remover atalhos antigos da versão de /usr/share/applications:
rm /usr/share/applications/yuzu-config.desktop 2>/dev/null
rm /usr/share/applications/yuzuEA-config.desktop 2>/dev/null
rm /usr/share/applications/ryujinx-config.desktop 2>/dev/null
rm /usr/share/applications/ryujinxavalonia-config.desktop 2>/dev/null
rm /usr/share/applications/ryujinxldn-config.desktop 2>/dev/null
rm /usr/share/applications/yuzu-config.desktop 2>/dev/null
rm /usr/share/applications/yuzuea-config.desktop 2>/dev/null
rm /usr/share/applications/ryujinx-config.desktop 2>/dev/null
rm /usr/share/applications/ryujinxavalonia-config.desktop 2>/dev/null
rm /usr/share/applications/ryujinxldn-config.desktop 2>/dev/null
# gerar novos atalhos de desktop: 
generate-shortcut-launcher 'yuzu' 'yuzu'
generate-shortcut-launcher 'yuzuEA' 'yuzuEA'
generate-shortcut-launcher 'Ryujinx' 'ryujinx'
generate-shortcut-launcher 'Ryujinx-LDN' 'ryujinx-LDN'
generate-shortcut-launcher 'Ryujinx-Avalonia' 'ryujinx-Avalonia'
generate-shortcut-launcher 'switch-updater' 'switch-updater'
######################################################################
######################################################################
######################################################################
######################################################################
if [[ "$EMULATORS" == *"DEFAULT"* ]] || [[ "$EMULATORS" == *"default"* ]] || [[ "$EMULATORS" == *"ALL"* ]] || [[ "$EMULATORS" == *"all"* ]]; then
   EMULATORS="YUZU YUZUEA RYUJINX RYUJINXLDN RYUJINXAVALONIA"
   EMULATORS=$(echo "$EMULATORS ")
fi
if [ "$(echo $EMULATORS | grep "-")" = "" ]; then 
EMULATORS="$EMULATORS-"
fi
EMULATORS="$(echo $EMULATORS | sed 's/ /-/g')"
   # OBTER EMULADORES DO ARQUIVO DE CONFIGURAÇÃO -------------------------------------
   cfg=/userdata/system/switch/CONFIG.txt
   if [[ ! -f $cfg ]]; then 
      link_defaultconfig=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/batocera-switch-config.txt
      wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/CONFIG.txt" "$link_defaultconfig"
      ###curl -sSf "$link_defaultconfig" -o "/userdata/system/switch/CONFIG.txt"
   fi 
   dos2unix $cfg 1>/dev/null 2>/dev/null
   if [[ -f $cfg ]]; then 
      # verificar versão do arquivo de configuração e atualizar ---------------------------
      link_defaultconfig=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/batocera-switch-config.txt
      rm "/tmp/.CONFIG.txt" 2>/dev/null
      wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/tmp/.CONFIG.txt" "$link_defaultconfig"
      ###curl -sSf "$link_defaultconfig" -o "/tmp/.CONFIG.txt"
         currentver=$(cat "/userdata/system/switch/CONFIG.txt" | grep "(ver " | head -n1 | sed 's,^.*(ver ,,g' | cut -d ")" -f1)
         if [[ "$currentver" = "" ]]; then currentver=1.0.0; fi
         latestver=$(cat "/tmp/.CONFIG.txt" | grep "(ver " | head -n1 | sed 's,^.*(ver ,,g' | cut -d ")" -f1)
            currentver=$(echo "$currentver" | sed 's,\.,,g')
            latestver=$(echo "$latestver" | sed 's,\.,,g')            
               if [ $latestver -gt $currentver ]; then 
                  cp /tmp/.CONFIG.txt $cfg 2>/dev/null
                  echo -e "\nARQUIVO ~/switch/CONFIG.txt FOI ATUALIZADO!\n"
               fi
      # verificar versão do arquivo de configuração e atualizar ---------------------------
      EMULATORS=$(cat /userdata/system/switch/CONFIG.txt | grep "EMULATORS=" | cut -d "=" -f2 | head -n1 | cut -d \" -f2 | tr -d '\0')
         if [[ "$EMULATORS" == *"DEFAULT"* ]] || [[ "$EMULATORS" == *"default"* ]] || [[ "$EMULATORS" == *"ALL"* ]] || [[ "$EMULATORS" == *"all"* ]]; then
            EMULATORS="YUZU YUZUEA RYUJINX RYUJINXLDN RYUJINXAVALONIA"
         fi
         if [ "$(echo $EMULATORS | grep "-")" = "" ]; then 
            EMULATORS="$EMULATORS-"
            EMULATORS=$(echo $EMULATORS | sed 's/ /-/g')
         fi
   #echo "2EMULATORS=$EMULATORS"
   fi 
#exit 0
   # /OBTER EMULADORES DO ARQUIVO DE CONFIGURAÇÃO -------------------------------------
# -------------------------------------------------------------------
rm /tmp/updater-settings 2>/dev/null
if [[ "$UPDATES" = "LOCKED" ]] || [[ "$UPDATES" = "locked" ]]; then 
echo "updates=locked" >> /tmp/updater-settings 
fi 
if [[ "$UPDATES" = "UNLOCKED" ]] || [[ "$UPDATES" = "unlocked" ]]; then 
echo "updates=unlocked" >> /tmp/updater-settings 
fi 
# -------------------------------------------------------------------
rm /tmp/updater-mode 2>/dev/null
echo "MODE=$MODE" >> /tmp/updater-mode 
# -------------------------------------------------------------------
# obter animação
if [[ "$MODE" = "DISPLAY" ]] || [[ "$MODE" = "display" ]]; then 
   if [[ ( "$ANIMATION" = "YES" ) || ( "$ANIMATION" = "yes" ) ]]; then
   url_loader=https://github.com/uureel/batocera-switch/raw/main/system/switch/extra/loader.mp4
   loader=/userdata/system/switch/extra/loader.mp4 
      if [[ ! -e "$loader" ]]; then 
         wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O $loader $url_loader 2>/dev/null
         ###curl -sSf "$url_loader" -o "$loader"
      fi 
      if [[ -e "$loader" ]] && [[ "$(wc -c $loader | awk '{print $1}')" < "6918849" ]]; then 
         wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O $loader $url_loader 2>/dev/null
         ###curl -sSf "$url_loader" -o "$loader"
      fi
   fi
fi
# -------------------------------------------------------------------
# obter dependências tar 
# \\ 
link_tar=https://github.com/brunnosaint/batocera-switch/raw/main/system/switch/extra/batocera-switch-tar
link_libselinux=https://github.com/brunnosaint/batocera-switch/raw/main/system/switch/extra/batocera-switch-libselinux.so.1
if [[ -e "$extra/batocera-switch-tar" ]]; then 
chmod a+x "$extra/batocera-switch-tar"
else 
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$extra/batocera-switch-tar" "$link_tar"
###curl -sSf "$link_tar" -o "$extra/batocera-switch-tar"
chmod a+x "$extra/batocera-switch-tar"
fi
if [[ ! -e "/usr/lib/libselinux.so.1" ]]; then
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$extra/batocera-switch-libselinux.so.1" "$link_libselinux"
###curl -sSf "$link_libselinux" -o "$extra/batocera-switch-libselinux.so.1"
chmod a+x "$extra/batocera-switch-libselinux.so.1"
cp "$extra/batocera-switch-libselinux.so.1" "/usr/lib/libselinux.so.1" 2>/dev/null
fi
if [[ -e "/userdata/system/switch/extra/batocera-switch-libselinux.so.1" ]]; then 
   cp /userdata/system/switch/extra/batocera-switch-libselinux.so.1 cp /userdata/system/switch/extra/libselinux.so.1 2>/dev/null
fi
# //
# -------------------------------------------------------------------
rm /tmp/updater-textsize 2>/dev/null
   if [[ "$(echo $TEXT_SIZE | grep "AUTO")" != "" ]] || [[ "$(echo $TEXT_SIZE | grep "auto")" != "" ]]; then 
      echo "$TEXT_SIZE" >> /tmp/updater-textsize 
   fi
# -------------------------------------------------------------------
temp=/userdata/system/switch/extra/downloads
mkdir /userdata/system/switch 2>/dev/null
mkdir /userdata/system/switch/extra 2>/dev/null
mkdir /userdata/system/switch/extra/downloads 2>/dev/null
#clear 
# TEXT & THEME COLORS: 
###########################
X='\033[0m'               # / resetcolor
RED='\033[1;31m'          # red
BLUE='\033[1;34m'         # blue
GREEN='\033[1;32m'        # green
YELLOW='\033[1;33m'       # yellow
PURPLE='\033[1;35m'       # purple
CYAN='\033[1;36m'         # cyan
#-------------------------#
DARKRED='\033[0;31m'      # darkred
DARKBLUE='\033[0;34m'     # darkblue
DARKGREEN='\033[0;32m'    # darkgreen
DARKYELLOW='\033[0;33m'   # darkyellow
DARKPURPLE='\033[0;35m'   # darkpurple
DARKCYAN='\033[0;36m'     # darkcyan
#-------------------------#
WHITE='\033[0;37m'        # white
BLACK='\033[0;30m'        # black
###########################
# ANALISAR CORES PARA TEMAS:
# ---------------------------------------------------------------------------------- 
if [ "$TEXT_COLOR" = "RED" ]; then TEXT_COLOR="$RED"; fi
if [ "$TEXT_COLOR" = "BLUE" ]; then TEXT_COLOR="$BLUE"; fi
if [ "$TEXT_COLOR" = "GREEN" ]; then TEXT_COLOR="$GREEN"; fi
if [ "$TEXT_COLOR" = "YELLOW" ]; then TEXT_COLOR="$YELLOW"; fi
if [ "$TEXT_COLOR" = "PURPLE" ]; then TEXT_COLOR="$PURPLE"; fi
if [ "$TEXT_COLOR" = "CYAN" ]; then TEXT_COLOR="$CYAN"; fi
if [ "$TEXT_COLOR" = "DARKRED" ]; then TEXT_COLOR="$DARKRED"; fi
if [ "$TEXT_COLOR" = "DARKBLUE" ]; then TEXT_COLOR="$DARKBLUE"; fi
if [ "$TEXT_COLOR" = "DARKGREEN" ]; then TEXT_COLOR="$DARKGREEN"; fi
if [ "$TEXT_COLOR" = "DARKYELLOW" ]; then TEXT_COLOR="$DARKYELLOW"; fi
if [ "$TEXT_COLOR" = "DARKPURPLE" ]; then TEXT_COLOR="$DARKPURPLE"; fi
if [ "$TEXT_COLOR" = "DARKCYAN" ]; then TEXT_COLOR="$DARKCYAN"; fi
if [ "$TEXT_COLOR" = "WHITE" ]; then TEXT_COLOR="$WHITE"; fi
if [ "$TEXT_COLOR" = "BLACK" ]; then TEXT_COLOR="$BLACK"; fi
# ---------------------------------------------------------------------------------- 
if [ "$THEME_COLOR" = "RED" ]; then THEME_COLOR="$RED"; fi
if [ "$THEME_COLOR" = "BLUE" ]; then THEME_COLOR="$BLUE"; fi
if [ "$THEME_COLOR" = "GREEN" ]; then THEME_COLOR="$GREEN"; fi
if [ "$THEME_COLOR" = "YELLOW" ]; then THEME_COLOR="$YELLOW"; fi
if [ "$THEME_COLOR" = "PURPLE" ]; then THEME_COLOR="$PURPLE"; fi
if [ "$THEME_COLOR" = "CYAN" ]; then THEME_COLOR="$CYAN"; fi
if [ "$THEME_COLOR" = "DARKRED" ]; then THEME_COLOR="$DARKRED"; fi
if [ "$THEME_COLOR" = "DARKBLUE" ]; then THEME_COLOR="$DARKBLUE"; fi
if [ "$THEME_COLOR" = "DARKGREEN" ]; then THEME_COLOR="$DARKGREEN"; fi
if [ "$THEME_COLOR" = "DARKYELLOW" ]; then THEME_COLOR="$DARKYELLOW"; fi
if [ "$THEME_COLOR" = "DARKPURPLE" ]; then THEME_COLOR="$DARKPURPLE"; fi
if [ "$THEME_COLOR" = "DARKCYAN" ]; then THEME_COLOR="$DARKCYAN"; fi
if [ "$THEME_COLOR" = "WHITE" ]; then THEME_COLOR="$WHITE"; fi
if [ "$THEME_COLOR" = "BLACK" ]; then THEME_COLOR="$BLACK"; fi
# ---------------------------------------------------------------------------------- 
if [ "$THEME_COLOR_OK" = "RED" ]; then THEME_COLOR_OK="$RED"; fi
if [ "$THEME_COLOR_OK" = "BLUE" ]; then THEME_COLOR_OK="$BLUE"; fi
if [ "$THEME_COLOR_OK" = "GREEN" ]; then THEME_COLOR_OK="$GREEN"; fi
if [ "$THEME_COLOR_OK" = "YELLOW" ]; then THEME_COLOR_OK="$YELLOW"; fi
if [ "$THEME_COLOR_OK" = "PURPLE" ]; then THEME_COLOR_OK="$PURPLE"; fi
if [ "$THEME_COLOR_OK" = "CYAN" ]; then THEME_COLOR_OK="$CYAN"; fi
if [ "$THEME_COLOR_OK" = "DARKRED" ]; then THEME_COLOR_OK="$DARKRED"; fi
if [ "$THEME_COLOR_OK" = "DARKBLUE" ]; then THEME_COLOR_OK="$DARKBLUE"; fi
if [ "$THEME_COLOR_OK" = "DARKGREEN" ]; then THEME_COLOR_OK="$DARKGREEN"; fi
if [ "$THEME_COLOR_OK" = "DARKYELLOW" ]; then THEME_COLOR_OK="$DARKYELLOW"; fi
if [ "$THEME_COLOR_OK" = "DARKPURPLE" ]; then THEME_COLOR_OK="$DARKPURPLE"; fi
if [ "$THEME_COLOR_OK" = "DARKCYAN" ]; then THEME_COLOR_OK="$DARKCYAN"; fi
if [ "$THEME_COLOR_OK" = "WHITE" ]; then THEME_COLOR_OK="$WHITE"; fi
if [ "$THEME_COLOR_OK" = "BLACK" ]; then THEME_COLOR_OK="$BLACK"; fi
# ---------------------------------------------------------------------------------- 
if [ "$THEME_COLOR_YUZU" = "RED" ]; then THEME_COLOR_YUZU="$RED"; fi
if [ "$THEME_COLOR_YUZU" = "BLUE" ]; then THEME_COLOR_YUZU="$BLUE"; fi
if [ "$THEME_COLOR_YUZU" = "GREEN" ]; then THEME_COLOR_YUZU="$GREEN"; fi
if [ "$THEME_COLOR_YUZU" = "YELLOW" ]; then THEME_COLOR_YUZU="$YELLOW"; fi
if [ "$THEME_COLOR_YUZU" = "PURPLE" ]; then THEME_COLOR_YUZU="$PURPLE"; fi
if [ "$THEME_COLOR_YUZU" = "CYAN" ]; then THEME_COLOR_YUZU="$CYAN"; fi
if [ "$THEME_COLOR_YUZU" = "DARKRED" ]; then THEME_COLOR_YUZU="$DARKRED"; fi
if [ "$THEME_COLOR_YUZU" = "DARKBLUE" ]; then THEME_COLOR_YUZU="$DARKBLUE"; fi
if [ "$THEME_COLOR_YUZU" = "DARKGREEN" ]; then THEME_COLOR_YUZU="$DARKGREEN"; fi
if [ "$THEME_COLOR_YUZU" = "DARKYELLOW" ]; then THEME_COLOR_YUZU="$DARKYELLOW"; fi
if [ "$THEME_COLOR_YUZU" = "DARKPURPLE" ]; then THEME_COLOR_YUZU="$DARKPURPLE"; fi
if [ "$THEME_COLOR_YUZU" = "DARKCYAN" ]; then THEME_COLOR_YUZU="$DARKCYAN"; fi
if [ "$THEME_COLOR_YUZU" = "WHITE" ]; then THEME_COLOR_YUZU="$WHITE"; fi
if [ "$THEME_COLOR_YUZU" = "BLACK" ]; then THEME_COLOR_YUZU="$BLACK"; fi
# ---------------------------------------------------------------------------------- 
if [ "$THEME_COLOR_YUZUEA" = "RED" ]; then THEME_COLOR_YUZUEA="$RED"; fi
if [ "$THEME_COLOR_YUZUEA" = "BLUE" ]; then THEME_COLOR_YUZUEA="$BLUE"; fi
if [ "$THEME_COLOR_YUZUEA" = "GREEN" ]; then THEME_COLOR_YUZUEA="$GREEN"; fi
if [ "$THEME_COLOR_YUZUEA" = "YELLOW" ]; then THEME_COLOR_YUZUEA="$YELLOW"; fi
if [ "$THEME_COLOR_YUZUEA" = "PURPLE" ]; then THEME_COLOR_YUZUEA="$PURPLE"; fi
if [ "$THEME_COLOR_YUZUEA" = "CYAN" ]; then THEME_COLOR_YUZUEA="$CYAN"; fi
if [ "$THEME_COLOR_YUZUEA" = "DARKRED" ]; then THEME_COLOR_YUZUEA="$DARKRED"; fi
if [ "$THEME_COLOR_YUZUEA" = "DARKBLUE" ]; then THEME_COLOR_YUZUEA="$DARKBLUE"; fi
if [ "$THEME_COLOR_YUZUEA" = "DARKGREEN" ]; then THEME_COLOR_YUZUEA="$DARKGREEN"; fi
if [ "$THEME_COLOR_YUZUEA" = "DARKYELLOW" ]; then THEME_COLOR_YUZUEA="$DARKYELLOW"; fi
if [ "$THEME_COLOR_YUZUEA" = "DARKPURPLE" ]; then THEME_COLOR_YUZUEA="$DARKPURPLE"; fi
if [ "$THEME_COLOR_YUZUEA" = "DARKCYAN" ]; then THEME_COLOR_YUZUEA="$DARKCYAN"; fi
if [ "$THEME_COLOR_YUZUEA" = "WHITE" ]; then THEME_COLOR_YUZUEA="$WHITE"; fi
if [ "$THEME_COLOR_YUZUEA" = "BLACK" ]; then THEME_COLOR_YUZUEA="$BLACK"; fi
# ---------------------------------------------------------------------------------- 
if [ "$THEME_COLOR_RYUJINX" = "RED" ]; then THEME_COLOR_RYUJINX="$RED"; fi
if [ "$THEME_COLOR_RYUJINX" = "BLUE" ]; then THEME_COLOR_RYUJINX="$BLUE"; fi
if [ "$THEME_COLOR_RYUJINX" = "GREEN" ]; then THEME_COLOR_RYUJINX="$GREEN"; fi
if [ "$THEME_COLOR_RYUJINX" = "YELLOW" ]; then THEME_COLOR_RYUJINX="$YELLOW"; fi
if [ "$THEME_COLOR_RYUJINX" = "PURPLE" ]; then THEME_COLOR_RYUJINX="$PURPLE"; fi
if [ "$THEME_COLOR_RYUJINX" = "CYAN" ]; then THEME_COLOR_RYUJINX="$CYAN"; fi
if [ "$THEME_COLOR_RYUJINX" = "DARKRED" ]; then THEME_COLOR_RYUJINX="$DARKRED"; fi
if [ "$THEME_COLOR_RYUJINX" = "DARKBLUE" ]; then THEME_COLOR_RYUJINX="$DARKBLUE"; fi
if [ "$THEME_COLOR_RYUJINX" = "DARKGREEN" ]; then THEME_COLOR_RYUJINX="$DARKGREEN"; fi
if [ "$THEME_COLOR_RYUJINX" = "DARKYELLOW" ]; then THEME_COLOR_RYUJINX="$DARKYELLOW"; fi
if [ "$THEME_COLOR_RYUJINX" = "DARKPURPLE" ]; then THEME_COLOR_RYUJINX="$DARKPURPLE"; fi
if [ "$THEME_COLOR_RYUJINX" = "DARKCYAN" ]; then THEME_COLOR_RYUJINX="$DARKCYAN"; fi
if [ "$THEME_COLOR_RYUJINX" = "WHITE" ]; then THEME_COLOR_RYUJINX="$WHITE"; fi
if [ "$THEME_COLOR_RYUJINX" = "BLACK" ]; then THEME_COLOR_RYUJINX="$BLACK"; fi
# ---------------------------------------------------------------------------------- 
if [ "$THEME_COLOR_RYUJINXLDN" = "RED" ]; then THEME_COLOR_RYUJINXLDN="$RED"; fi
if [ "$THEME_COLOR_RYUJINXLDN" = "BLUE" ]; then THEME_COLOR_RYUJINXLDN="$BLUE"; fi
if [ "$THEME_COLOR_RYUJINXLDN" = "GREEN" ]; then THEME_COLOR_RYUJINXLDN="$GREEN"; fi
if [ "$THEME_COLOR_RYUJINXLDN" = "YELLOW" ]; then THEME_COLOR_RYUJINXLDN="$YELLOW"; fi
if [ "$THEME_COLOR_RYUJINXLDN" = "PURPLE" ]; then THEME_COLOR_RYUJINXLDN="$PURPLE"; fi
if [ "$THEME_COLOR_RYUJINXLDN" = "CYAN" ]; then THEME_COLOR_RYUJINXLDN="$CYAN"; fi
if [ "$THEME_COLOR_RYUJINXLDN" = "DARKRED" ]; then THEME_COLOR_RYUJINXLDN="$DARKRED"; fi
if [ "$THEME_COLOR_RYUJINXLDN" = "DARKBLUE" ]; then THEME_COLOR_RYUJINXLDN="$DARKBLUE"; fi
if [ "$THEME_COLOR_RYUJINXLDN" = "DARKGREEN" ]; then THEME_COLOR_RYUJINXLDN="$DARKGREEN"; fi
if [ "$THEME_COLOR_RYUJINXLDN" = "DARKYELLOW" ]; then THEME_COLOR_RYUJINXLDN="$DARKYELLOW"; fi
if [ "$THEME_COLOR_RYUJINXLDN" = "DARKPURPLE" ]; then THEME_COLOR_RYUJINXLDN="$DARKPURPLE"; fi
if [ "$THEME_COLOR_RYUJINXLDN" = "DARKCYAN" ]; then THEME_COLOR_RYUJINXLDN="$DARKCYAN"; fi
if [ "$THEME_COLOR_RYUJINXLDN" = "WHITE" ]; then THEME_COLOR_RYUJINXLDN="$WHITE"; fi
if [ "$THEME_COLOR_RYUJINXLDN" = "BLACK" ]; then THEME_COLOR_RYUJINXLDN="$BLACK"; fi
# ---------------------------------------------------------------------------------- 
if [ "$THEME_COLOR_RYUJINXAVALONIA" = "RED" ]; then THEME_COLOR_RYUJINXAVALONIA="$RED"; fi
if [ "$THEME_COLOR_RYUJINXAVALONIA" = "BLUE" ]; then THEME_COLOR_RYUJINXAVALONIA="$BLUE"; fi
if [ "$THEME_COLOR_RYUJINXAVALONIA" = "GREEN" ]; then THEME_COLOR_RYUJINXAVALONIA="$GREEN"; fi
if [ "$THEME_COLOR_RYUJINXAVALONIA" = "YELLOW" ]; then THEME_COLOR_RYUJINXAVALONIA="$YELLOW"; fi
if [ "$THEME_COLOR_RYUJINXAVALONIA" = "PURPLE" ]; then THEME_COLOR_RYUJINXAVALONIA="$PURPLE"; fi
if [ "$THEME_COLOR_RYUJINXAVALONIA" = "CYAN" ]; then THEME_COLOR_RYUJINXAVALONIA="$CYAN"; fi
if [ "$THEME_COLOR_RYUJINXAVALONIA" = "DARKRED" ]; then THEME_COLOR_RYUJINXAVALONIA="$DARKRED"; fi
if [ "$THEME_COLOR_RYUJINXAVALONIA" = "DARKBLUE" ]; then THEME_COLOR_RYUJINXAVALONIA="$DARKBLUE"; fi
if [ "$THEME_COLOR_RYUJINXAVALONIA" = "DARKGREEN" ]; then THEME_COLOR_RYUJINXAVALONIA="$DARKGREEN"; fi
if [ "$THEME_COLOR_RYUJINXAVALONIA" = "DARKYELLOW" ]; then THEME_COLOR_RYUJINXAVALONIA="$DARKYELLOW"; fi
if [ "$THEME_COLOR_RYUJINXAVALONIA" = "DARKPURPLE" ]; then THEME_COLOR_RYUJINXAVALONIA="$DARKPURPLE"; fi
if [ "$THEME_COLOR_RYUJINXAVALONIA" = "DARKCYAN" ]; then THEME_COLOR_RYUJINXAVALONIA="$DARKCYAN"; fi
if [ "$THEME_COLOR_RYUJINXAVALONIA" = "WHITE" ]; then THEME_COLOR_RYUJINXAVALONIA="$WHITE"; fi
if [ "$THEME_COLOR_RYUJINXAVALONIA" = "BLACK" ]; then THEME_COLOR_RYUJINXAVALONIA="$BLACK"; fi
# ---------------------------------------------------------------------------------- 
# SUBSTITUIR CORES PARA MODO CONSOLE: 
   if [[ -e "/tmp/updater-mode" ]]; then 
      MODE=$(cat /tmp/updater-mode | grep MODE | cut -d "=" -f2)
   fi
      if [[ "$MODE" = "CONSOLE" ]]; then 
         TEXT_COLOR=$X 
         THEME_COLOR=$X
         THEME_COLOR_OK=$X
         THEME_COLOR_YUZU=$X
         THEME_COLOR_YUZUEA=$X
         THEME_COLOR_RYUJINX=$X
         THEME_COLOR_RYUJINXLDN=$X
         THEME_COLOR_RYUJINXAVALONIA=$X
      fi
# PREPARAR COOKIE PARA FUNÇÕES: 
f=/userdata/system/switch/extra/batocera-switch-updatersettings
rm -rf "$f"
echo "TEXT_SIZE=$TEXT_SIZE" >> "$f"
echo "TEXT_COLOR=$TEXT_COLOR" >> "$f"
echo "THEME_COLOR=$THEME_COLOR" >> "$f"
echo "THEME_COLOR_YUZU=$THEME_COLOR_YUZU" >> "$f"
echo "THEME_COLOR_YUZUEA=$THEME_COLOR_YUZUEA" >> "$f"
echo "THEME_COLOR_RYUJINX=$THEME_COLOR_RYUJINX" >> "$f"
echo "THEME_COLOR_RYUJINXAVALONIA=$THEME_COLOR_RYUJINXAVALONIA" >> "$f"
echo "THEME_COLOR_RYUJINXLDN=$THEME_COLOR_RYUJINXLDN" >> "$f"
echo "THEME_COLOR_OK=$THEME_COLOR_OK" >> "$f"
   # OBTER EMULADORES DO ARQUIVO DE CONFIGURAÇÃO -------------------------------------
   cfg=/userdata/system/switch/CONFIG.txt
   dos2unix $cfg 1>/dev/null 2>/dev/null
   if [[ -e "$cfg" ]]; then 
      EMULATORS="$(cat "$cfg" | grep "EMULATORS=" | cut -d "=" -f2 | head -n1 | cut -d \" -f2 | tr -d '\0')"
         if [[ "$EMULATORS" == *"DEFAULT"* ]] || [[ "$EMULATORS" == *"default"* ]] || [[ "$EMULATORS" == *"ALL"* ]] || [[ "$EMULATORS" == *"all"* ]]; then
            EMULATORS="YUZU YUZUEA RYUJINX RYUJINXLDN RYUJINXAVALONIA"
         fi 
         if [ "$(echo $EMULATORS | grep "-")" = "" ]; then 
            EMULATORS="$EMULATORS-"
            EMULATORS="$(echo $EMULATORS | sed 's/ /-/g')"
         fi
   fi 
   # /OBTER EMULADORES DO ARQUIVO DE CONFIGURAÇÃO -------------------------------------
echo "EMULATORS=$EMULATORS" >> "$f"
####################################################################################
function update_emulator {
E=$1 && N=$2
link_yuzu="$4"
link_yuzuea="$5"
link_ryujinx="$6"
link_ryujinxldn="$7"
link_ryujinxavalonia="$8"
# ---------------------------------------------------------------------------------- 
# BLOQUEAR ATUALIZAÇÕES PARA COMPATIBILIDADE COM AUTOCONTROLADOR RYUJINX: 
#link_ryujinx=https://github.com/uureel/batocera.pro/raw/main/switch/extra/ryujinx-1.1.382-linux_x64.tar.gz
#link_ryujinxavalonia=https://github.com/uureel/batocera.pro/raw/main/switch/extra/test-ava-ryujinx-1.1.382-linux_x64.tar.gz
updates=$(cat /tmp/updater-settings | grep "updates=locked" | cut -d "=" -f2)
   if [[ "$updates" = "locked" ]]; then 
      locked=1
      link_ryujinx=https://github.com/uureel/batocera.pro/raw/main/switch/extra/ryujinx-1.1.382-linux_x64.tar.gz
      link_ryujinxavalonia=https://github.com/uureel/batocera.pro/raw/main/switch/extra/test-ava-ryujinx-1.1.382-linux_x64.tar.gz
   fi 
   # desbloquear para v37 
   if [[ "$(uname -a | awk '{print $3}')" > "6.2" ]]; then 
      locked=0
      release_ryujinx=$(curl -s --retry 5 --retry-delay 1 --retry-connrefused https://github.com/Ryujinx/release-channel-master | grep "/release-channel-master/releases/tag/" | sed 's,^.*/release-channel-master/releases/tag/,,g' | cut -d \" -f1)
      release_ryujinx_vanilla="$release_ryujinx"
      if [[ "$release_ryujinx" > "1.1.1215" ]]; then release_ryujinx_vanilla="1.1.1215"; fi
      link_ryujinx=https://github.com/Ryujinx/release-channel-master/releases/download/$release_ryujinx_vanilla/ryujinx-$release_ryujinx_vanilla-linux_x64.tar.gz
      link_ryujinxavalonia=https://github.com/Ryujinx/release-channel-master/releases/download/$release_ryujinx/test-ava-ryujinx-$release_ryujinx-linux_x64.tar.gz
   fi
   # desbloquear para v<=36 // usar configurações do arquivo de config 
   if [[ "$(uname -a | awk '{print $3}')" < "6.2" ]] || [[ "$(uname -a | awk '{print $3}')" = "6.2" ]]; then 
      locked=0
      release_ryujinx=$(curl -s --retry 5 --retry-delay 1 --retry-connrefused https://github.com/Ryujinx/release-channel-master | grep "/release-channel-master/releases/tag/" | sed 's,^.*/release-channel-master/releases/tag/,,g' | cut -d \" -f1)
      link_ryujinx=https://github.com/Ryujinx/release-channel-master/releases/download/$release_ryujinx/ryujinx-$release_ryujinx-linux_x64.tar.gz
      link_ryujinxavalonia=https://github.com/Ryujinx/release-channel-master/releases/download/$release_ryujinx/test-ava-ryujinx-$release_ryujinx-linux_x64.tar.gz
   fi 
# ----------------------------------------------------------------------------------
# passar cookie de info: 
cookie=/userdata/system/switch/extra/updates.txt
   rm $cookie 2>/dev/null 
   if [[ "$updates" = "locked" ]] || [[ "$locked" = 1 ]]; then 
      echo "locked" >> $cookie 2>/dev/null
   fi 
   if [[ "$updates" = "unlocked" ]] || [[ "$locked" = 0 ]]; then 
      echo "unlocked" >> $cookie 2>/dev/null
   fi
# ----------------------------------------------------------------------------------
# CAMINHOS: 
path_yuzu=/userdata/system/switch/yuzu.AppImage
path_yuzuea=/userdata/system/switch/yuzuEA.AppImage
path_ryujinx=/userdata/system/switch/Ryujinx.AppImage
path_ryujinxldn=/userdata/system/switch/Ryujinx-LDN.AppImage
path_ryujinxavalonia=/userdata/system/switch/Ryujinx-Avalonia.AppImage
# ---------------------------------------------------------------------------------- 
# LER CONFIGURAÇÕES DO COOKIE: 
cookie=/userdata/system/switch/extra/batocera-switch-updatersettings
TEXT_SIZE=$(cat $cookie | grep "TEXT_SIZE=" | cut -d "=" -f 2)
TEXT_COLOR=$(cat $cookie | grep "TEXT_COLOR=" | cut -d "=" -f 2)
THEME_COLOR=$(cat $cookie | grep "THEME_COLOR=" | cut -d "=" -f 2)
THEME_COLOR_YUZU=$(cat $cookie | grep "THEME_COLOR_YUZU=" | cut -d "=" -f 2)
THEME_COLOR_YUZUEA=$(cat $cookie | grep "THEME_COLOR_YUZUEA=" | cut -d "=" -f 2)
THEME_COLOR_RYUJINX=$(cat $cookie | grep "THEME_COLOR_RYUJINX=" | cut -d "=" -f 2)
THEME_COLOR_RYUJINXLDN=$(cat $cookie | grep "THEME_COLOR_RYUJINXLDN=" | cut -d "=" -f 2)
THEME_COLOR_RYUJINXAVALONIA=$(cat $cookie | grep "THEME_COLOR_RYUJINXAVALONIA=" | cut -d "=" -f 2)
THEME_COLOR_OK=$(cat $cookie | grep "THEME_COLOR_OK=" | cut -d "=" -f 2)
EMULATORS="$(cat $cookie | grep "EMULATORS=" | cut -d "=" -f 2)"
#
# --------------
# --------------
# --------------
# \\ arquivo de config
# ---------------------------------------------------------------------------------- 
# ---------------------------------------------------------------------------------- 
# USAR CONFIGURAÇÕES PERSONALIZADAS DO ATUALIZADOR DO ARQUIVO DE CONFIGURAÇÃO:
# /USERDATA/SYSTEM/SWITCH/CONFIG.TXT
# ---------------------------------------------------------------------------------- 
# ---------------------------------------------------------------------------------- 
cfg=/userdata/system/switch/CONFIG.txt
dos2unix $cfg 1>/dev/null 2>/dev/null
if [[ ! -e "$cfg" ]]; then 
link_defaultconfig=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/batocera-switch-config.txt
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/CONFIG.txt" "$link_defaultconfig"
###curl -sSf "$link_defaultconfig" -o "/userdata/system/switch/CONFIG.txt"
fi 
if [[ -e "$cfg" ]]; then 
   # obter 
   # \\\
   ### emuladores  
   EMULATORS="$(cat "$cfg" | grep "EMULATORS=" | cut -d "=" -f2 | head -n1 | cut -d \" -f2 | tr -d '\0')"
   EMULATORS=$(echo "$EMULATORS ")
      if [[ "$EMULATORS" == *"DEFAULT"* ]] || [[ "$EMULATORS" == *"default"* ]] || [[ "$EMULATORS" == *"ALL"* ]] || [[ "$EMULATORS" == *"all"* ]]; then
         EMULATORS="YUZU YUZUEA RYUJINX RYUJINXLDN RYUJINXAVALONIA"
      fi
      if [ "$(echo $EMULATORS | grep "-")" = "" ]; then 
         EMULATORS="$EMULATORS-"
         EMULATORS=$(echo $EMULATORS | sed 's/ /-/g')
      fi
   ### texto/cores
   TEXT_SIZE=$(cat $cfg | grep "TEXT_SIZE=" | cut -d "=" -f 2 | sed 's, ,,g' | head -n1 | tr -d '\0')
   TEXT_COLOR=$(cat $cfg | grep "TEXT_COLOR=" | cut -d "=" -f 2 | sed 's, ,,g' | head -n1 | tr -d '\0')
   THEME_COLOR=$(cat $cfg | grep "THEME_COLOR=" | cut -d "=" -f 2 | sed 's, ,,g' | head -n1 | tr -d '\0')
   THEME_COLOR_YUZU=$(cat $cfg | grep "THEME_COLOR_YUZU=" | cut -d "=" -f 2 | sed 's, ,,g' | head -n1 | tr -d '\0')
   THEME_COLOR_YUZUEA=$(cat $cfg | grep "THEME_COLOR_YUZUEA=" | cut -d "=" -f 2 | sed 's, ,,g' | head -n1 | tr -d '\0')
   THEME_COLOR_RYUJINX=$(cat $cfg | grep "THEME_COLOR_RYUJINX=" | cut -d "=" -f 2 | sed 's, ,,g' | head -n1 | tr -d '\0')
   THEME_COLOR_RYUJINXLDN=$(cat $cfg | grep "THEME_COLOR_RYUJINXLDN=" | cut -d "=" -f 2 | sed 's, ,,g' | head -n1 | tr -d '\0')
   THEME_COLOR_RYUJINXAVALONIA=$(cat $cfg | grep "THEME_COLOR_RYUJINXAVALONIA=" | cut -d "=" -f 2 | sed 's, ,,g' | head -n1 | tr -d '\0')
   THEME_COLOR_OK=$(cat $cfg | grep "THEME_COLOR_OK=" | cut -d "=" -f 2 | sed 's, ,,g' | head -n1 | tr -d '\0')
      # TEXT & THEME COLORS: 
      ###########################
      X='\033[0m'               # / resetcolor
      RED='\033[1;31m'          # red
      BLUE='\033[1;34m'         # blue
      GREEN='\033[1;32m'        # green
      YELLOW='\033[1;33m'       # yellow
      PURPLE='\033[1;35m'       # purple
      CYAN='\033[1;36m'         # cyan
      #-------------------------#
      DARKRED='\033[0;31m'      # darkred
      DARKBLUE='\033[0;34m'     # darkblue
      DARKGREEN='\033[0;32m'    # darkgreen
      DARKYELLOW='\033[0;33m'   # darkyellow
      DARKPURPLE='\033[0;35m'   # darkpurple
      DARKCYAN='\033[0;36m'     # darkcyan
      #-------------------------#
      WHITE='\033[0;37m'        # white
      BLACK='\033[0;30m'        # black
      ###########################
      # ANALISAR CORES PARA TEMAS:
      # ------------------------------------------------------------------...(truncated 107973 characters)... /userdata/system/switch/extra/nsz.zip 2>/dev/null
   cd /userdata/system/ 
# -------------------------------------------------------------------
# preparar libs gdk/svg para ryujinx / necessário para config de controle GUI 
   if [[ ! -f "/userdata/system/switch/extra/lib.tar.gz" ]]; then 
      wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/extra/lib.tar.gz" "$extraurl/lib.tar.gz"
      ###curl -sSf "$extraurl/lib.tar.gz" -o "/userdata/system/switch/extra/lib.tar.gz"
         cd /userdata/system/switch/extra/ 
         rm -rf /userdata/system/switch/extra/lib 2>/dev/null
         tar -xf /userdata/system/switch/extra/lib.tar.gz 
   else 
      if [[ "$(md5sum "/userdata/system/switch/extra/lib.tar.gz" | awk '{print $1}')" != "83952eb2897a61337ca10ff0e19c672f" ]]; then
      rm /userdata/system/switch/extra/lib.tar.gz 2>/dev/null
      wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/extra/lib.tar.gz" "$extraurl/lib.tar.gz"
      ###curl -sSf "$extraurl/lib.tar.gz" -o "/userdata/system/switch/extra/lib.tar.gz"
         cd /userdata/system/switch/extra/ 
         rm -rf /userdata/system/switch/extra/lib 2>/dev/null
         tar -xf /userdata/system/switch/extra/lib.tar.gz 
      fi
   fi
#   cp -rL /userdata/system/switch/extra/lib/* /userdata/system/switch/extra/ryujinx/ 2>/dev/null
#   cp -rL /userdata/system/switch/extra/lib/* /userdata/system/switch/extra/ryujinxldn/ 2>/dev/null
#   cp -rL /userdata/system/switch/extra/lib/* /userdata/system/switch/extra/ryujinxavalonia/ 2>/dev/null
   cd /userdata/system/ 
# -------------------------------------------------------------------
# obter ryujinx-controller-patcher.sh 
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/extra/ryujinx-controller-patcher.sh" "$extraurl/ryujinx-controller-patcher.sh"
   ###curl -sSf "$extraurl/ryujinx-controller-patcher.sh" -o "/userdata/system/switch/extra/ryujinx-controller-patcher.sh"
   dos2unix /userdata/system/switch/extra/ryujinx-controller-patcher.sh 2>/dev/null 
   chmod a+x /userdata/system/switch/extra/ryujinx-controller-patcher.sh 2>/dev/null  
# -------------------------------------------------------------------
# obter yuzu-controller-patcher.sh 
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/extra/yuzu-controller-patcher.sh" "$extraurl/yuzu-controller-patcher.sh"
   ###curl -sSf "$extraurl/yuzu-controller-patcher.sh" -o "/userdata/system/switch/extra/yuzu-controller-patcher.sh"
   dos2unix /userdata/system/switch/extra/yuzu-controller-patcher.sh 2>/dev/null 
   chmod a+x /userdata/system/switch/extra/yuzu-controller-patcher.sh 2>/dev/null  
# -------------------------------------------------------------------
# preparar patcher 
url_patcher="https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/batocera-switch-patcher.sh"
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/extra/batocera-switch-patcher.sh" "$url_patcher"
   ###curl -sSf "$url_patcher" -o "/userdata/system/switch/extra/batocera-switch-patcher.sh"
   dos2unix ~/switch/extra/batocera-switch-patcher.sh 2>/dev/null
   chmod a+x ~/switch/extra/batocera-switch-patcher.sh 2>/dev/null
#
# -------------------------------------------------------------------
# PREPARAR ARQUIVO BATOCERA-SWITCH-STARTUP
# -------------------------------------------------------------------
#
f=/userdata/system/switch/extra/batocera-switch-startup
rm "$f" 2>/dev/null 
# 
echo '#!/bin/bash' >> "$f"
echo '#' >> "$f"
#\ verificar idioma
echo '#\ verificar idioma ' >> "$f"
echo '/userdata/system/switch/extra/batocera-switch-translator.sh 2>/dev/null &' >> "$f"
#\ preparar sistema 
echo '#\ preparar sistema ' >> "$f"
echo 'cp /userdata/system/switch/extra/batocera-switch-rev /usr/bin/rev 2>/dev/null ' >> "$f"
#echo 'rm /userdata/system/switch/logs/* 2>/dev/null ' >> "$f" 
echo 'mkdir -p /userdata/system/switch/logs 2>/dev/null ' >> "$f"
echo 'sysctl -w vm.max_map_count=2147483642 1>/dev/null' >> "$f"
echo 'extra=/userdata/system/switch/extra' >> "$f"
echo 'cp $extra/*.desktop /usr/share/applications/ 2>/dev/null' >> "$f"
echo '#' >> "$f"
#echo 'cp $extra/lib* /lib/ 2>/dev/null' >> "$f"
echo 'if [[ -e "/lib/libthai.so.0.3.1" ]] || [[ -e "/usr/lib/libthai.so.0.3.1" ]]; then echo 1>/dev/null; else cp /userdata/system/switch/extra/libthai.so.0.3.1 /usr/lib/libthai.so.0.3.1 2>/dev/null; fi' >> "$f"
echo 'if [[ -e "/lib/libthai.so.0.3" ]] || [[ -e "/usr/lib/libthai.so.0.3" ]]; then echo 1>/dev/null; else cp /userdata/system/switch/extra/batocera-switch-libthai.so.0.3 /usr/lib/libthai.so.0.3 2>/dev/null; fi' >> "$f"
echo 'if [[ -e "/lib/libselinux.so.1" ]] || [[ -e "/usr/lib/libselinux.so.1" ]]; then echo 1>/dev/null; else cp /userdata/system/switch/extra/batocera-switch-libselinux.so.1 /usr/lib/libselinux.so.1 2>/dev/null; fi' >> "$f"
echo 'if [[ -e "/lib/libtinfo.so.6" ]] || [[ -e "/usr/lib/libtinfo.so.6" ]]; then echo 1>/dev/null; else cp /userdata/system/switch/extra/batocera-switch-libtinfo.so.6 /usr/lib/libtinfo.so.6 2>/dev/null; fi' >> "$f"
echo '#' >> "$f"
#\ linkar pastas de config do ryujinx 
echo '#\ linkar pastas de config do ryujinx ' >> "$f"
echo 'mkdir /userdata/system/configs 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs/Ryujinx 2>/dev/null' >> "$f"
echo 'mv /userdata/system/configs/Ryujinx /userdata/system/configs/Ryujinx_tmp 2>/dev/null' >> "$f"
echo 'cp -rL /userdata/system/.config/Ryujinx/* /userdata/configs/Ryujinx_tmp 2>/dev/null' >> "$f"
echo 'rm -rf /userdata/system/.config/Ryujinx' >> "$f"
echo 'mv /userdata/system/configs/Ryujinx_tmp /userdata/system/configs/Ryujinx 2>/dev/null' >> "$f"
echo 'ln -s /userdata/system/configs/Ryujinx /userdata/system/.config/Ryujinx 2>/dev/null' >> "$f"
echo 'rm /userdata/system/configs/Ryujinx/Ryujinx 2>/dev/null' >> "$f"
echo '#' >> "$f"
#
#\ linkar pastas de saves do ryujinx 
echo '#\ linkar pastas de saves do ryujinx ' >> "$f"
echo 'mkdir /userdata/saves 2>/dev/null' >> "$f"
echo 'mkdir /userdata/saves/Ryujinx 2>/dev/null' >> "$f"
echo 'mv /userdata/saves/Ryujinx /userdata/saves/Ryujinx_tmp 2>/dev/null' >> "$f"
echo 'cp -rL /userdata/system/configs/Ryujinx/bis/user/save/* /userdata/saves/Ryujinx_tmp/ 2>/dev/null' >> "$f"
echo 'rm -rf /userdata/system/configs/Ryujinx/bis/user/save 2>/dev/null' >> "$f"
echo 'mv /userdata/saves/Ryujinx_tmp /userdata/saves/Ryujinx 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs/Ryujinx 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs/Ryujinx/bis 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs/Ryujinx/bis/user 2>/dev/null' >> "$f"
echo 'ln -s /userdata/saves/Ryujinx /userdata/system/configs/Ryujinx/bis/user/save 2>/dev/null' >> "$f"
echo 'rm /userdata/saves/Ryujinx/Ryujinx 2>/dev/null' >> "$f"
echo 'if [ ! -L /userdata/system/configs/Ryujinx/bis/user/save ]; then mkdir /userdata/system/configs/Ryujinx/bis/user/save 2>/dev/null; rsync -au /userdata/saves/Ryujinx/ /userdata/system/configs/Ryujinx/bis/user/save/ 2>/dev/null; fi' >> "$f"
echo '#' >> "$f"
#
#\ linkar pastas de config do yuzu 
echo '#\ linkar pastas de config do yuzu ' >> "$f"
echo 'mkdir /userdata/system/configs 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs/yuzu 2>/dev/null' >> "$f"
echo 'mv /userdata/system/configs/yuzu /userdata/system/configs/yuzu_tmp 2>/dev/null' >> "$f"
echo 'cp -rL /userdata/system/.config/yuzu/* /userdata/configs/yuzu_tmp 2>/dev/null' >> "$f"
echo 'cp -rL /userdata/system/.local/share/yuzu/* /userdata/configs/yuzu_tmp 2>/dev/null' >> "$f"
echo 'rm -rf /userdata/system/.config/yuzu' >> "$f"
echo 'rm -rf /userdata/system/.local/share/yuzu' >> "$f"
echo 'mv /userdata/system/configs/yuzu_tmp /userdata/system/configs/yuzu 2>/dev/null' >> "$f"
echo 'ln -s /userdata/system/configs/yuzu /userdata/system/.config/yuzu 2>/dev/null' >> "$f"
echo 'ln -s /userdata/system/configs/yuzu /userdata/system/.local/share/yuzu 2>/dev/null' >> "$f"
echo 'rm /userdata/system/configs/yuzu/yuzu 2>/dev/null' >> "$f"
echo '#' >> "$f"
#
#\ linkar pastas de saves do yuzu
echo '#\ linkar pastas de saves do yuzu' >> "$f"
echo 'mkdir /userdata/saves 2>/dev/null' >> "$f"
echo 'mkdir /userdata/saves/yuzu 2>/dev/null' >> "$f"
echo 'mv /userdata/saves/yuzu /userdata/saves/yuzu_tmp 2>/dev/null' >> "$f"
echo 'cp -rL /userdata/system/configs/yuzu/nand/user/save/* /userdata/saves/yuzu_tmp/ 2>/dev/null' >> "$f"
echo 'rm -rf /userdata/system/configs/yuzu/nand/user/save 2>/dev/null' >> "$f"
echo 'mv /userdata/saves/yuzu_tmp /userdata/saves/yuzu 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs/yuzu 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs/yuzu/nand 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs/yuzu/nand/user 2>/dev/null' >> "$f"
echo 'ln -s /userdata/saves/yuzu /userdata/system/configs/yuzu/nand/user/save 2>/dev/null' >> "$f"
echo 'rm /userdata/saves/yuzu/yuzu 2>/dev/null' >> "$f"
echo 'if [ ! -L /userdata/system/configs/yuzu/nand/user/save ]; then mkdir /userdata/system/configs/yuzu/nand/user/save 2>/dev/null; rsync -au /userdata/saves/yuzu/ /userdata/system/configs/yuzu/nand/user/save/ 2>/dev/null; fi' >> "$f"
echo '#' >> "$f"
#
#\ linkar pastas de chaves do yuzu e ryujinx para bios/switch 
echo '#\ linkar pastas de chaves do yuzu e ryujinx para bios/switch ' >> "$f"
echo 'cp -rL /userdata/system/configs/yuzu/keys/* /userdata/bios/switch/ 2>/dev/null' >> "$f"
echo 'cp -rL /userdata/system/configs/Ryujinx/system/* /userdata/bios/switch/ 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs/yuzu 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs/Ryujinx 2>/dev/null' >> "$f"
echo 'mv /userdata/bios/switch /userdata/bios/switch_tmp 2>/dev/null' >> "$f"
echo 'rm -rf /userdata/system/configs/yuzu/keys 2>/dev/null' >> "$f"
echo 'rm -rf /userdata/system/configs/Ryujinx/system 2>/dev/null' >> "$f"
echo 'mv /userdata/bios/switch_tmp /userdata/bios/switch 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs/yuzu 2>/dev/null' >> "$f"
echo 'mkdir /userdata/system/configs/Ryujinx 2>/dev/null' >> "$f"
echo 'ln -s /userdata/bios/switch /userdata/system/configs/yuzu/keys 2>/dev/null' >> "$f"
echo 'ln -s /userdata/bios/switch /userdata/system/configs/Ryujinx/system 2>/dev/null' >> "$f"
echo 'if [ ! -L /userdata/system/configs/yuzu/keys ]; then mkdir /userdata/system/configs/yuzu/keys 2>/dev/null; cp -rL /userdata/bios/switch/*.keys /userdata/system/configs/yuzu/keys/ 2>/dev/null; fi' >> "$f"
echo 'if [ ! -L /userdata/system/configs/Ryujinx/system ]; then mkdir /userdata/system/configs/Ryujinx/system 2>/dev/null; cp -rL /userdata/bios/switch/*.keys /userdata/system/configs/Ryujinx/system/ 2>/dev/null; fi' >> "$f"
echo 'mkdir -p /userdata/system/configs/yuzu/keys 2>/dev/null; cp -rL /userdata/bios/switch/*.keys /userdata/system/configs/yuzu/keys/ 2>/dev/null ' >> "$f"
echo 'mkdir -p /userdata/system/.local/share/yuzu/keys 2>/dev/null; cp -rL /userdata/bios/switch/*.keys /userdata/system/.local/share/yuzu/keys/ 2>/dev/null ' >> "$f"
echo 'mkdir -p /userdata/system/configs/Ryujinx/system 2>/dev/null; cp -rL /userdata/bios/switch/*.keys /userdata/system/configs/Ryujinx/system/ 2>/dev/null ' >> "$f"
echo '#' >> "$f"
#
#\ corrigir problema da pasta batocera.linux para menu f1/apps tx to drizzt
echo "sed -i 's/inline_limit=\"20\"/inline_limit=\"256\"/' /etc/xdg/menus/batocera-applications.menu 2>/dev/null" >> "$f"
echo "sed -i 's/inline_limit=\"60\"/inline_limit=\"256\"/' /etc/xdg/menus/batocera-applications.menu 2>/dev/null" >> "$f"
echo '#' >> "$f"
#
#\ adicionar integração xdg com pcmanfm para configs de emu f1
echo '  fs=$(blkid | grep "$(df -h /userdata | awk '\''END {print $1}'\'')" | sed '\''s,^.*TYPE=,,g'\'' | sed '\''s,",,g'\'' | tr '\''a-z'\'' '\''A-Z'\'') ' >> "$f"
echo '    if [[ "$fs" == *"EXT"* ]] || [[ "$fs" == *"BTR"* ]]; then ' >> "$f"
echo '      /userdata/system/switch/extra/batocera-switch-xdg.sh ' >> "$f"
echo '    fi' >> "$f"
echo '#' >> "$f" 
#
dos2unix "$f" 2>/dev/null
chmod a+x "$f" 2>/dev/null
# -------------------------------------------------------------------
# & executar agora: 
      /userdata/system/switch/extra/batocera-switch-startup 2>/dev/null & 
      echo 1>/dev/null 2>/dev/null 
# -------------------------------------------------------------------
# ADICIONAR AO INÍCIO AUTOMÁTICO DO BATOCERA > /USERDATA/SYSTEM/CUSTOM.SH 
# -------------------------------------------------------------------
csh=/userdata/system/custom.sh; dos2unix $csh 2>/dev/null
startup="/userdata/system/switch/extra/batocera-switch-startup"
if [[ -f $csh ]];
   then
      tmp1=/tmp/tcsh1
      tmp2=/tmp/tcsh2
      remove="$startup"
      rm $tmp1 2>/dev/null; rm $tmp2 2>/dev/null
      nl=$(cat "$csh" | wc -l); nl1=$(($nl + 1))
         l=1; 
         for l in $(seq 1 $nl1); do
            ln=$(cat "$csh" | sed ""$l"q;d" );
               if [[ "$(echo "$ln" | grep "$remove")" != "" ]]; then :; 
                else 
                  if [[ "$l" = "1" ]]; then
                        if [[ "$(echo "$ln" | grep "#" | grep "/bin/" | grep "bash" )" != "" ]]; then :; else echo "$ln" >> "$tmp1"; fi
                     else 
                        echo "$ln" >> $tmp1;
                  fi
               fi            
            ((l++))
         done
          # 
          echo -e '#!/bin/bash' >> $tmp2
          echo -e "\n$startup \n" >> $tmp2          
          cat "$tmp1" | sed -e '/./b' -e :n -e 'N;s/\n$//;tn' >> "$tmp2"
          cp $tmp2 $csh 2>/dev/null; dos2unix $csh 2>/dev/null; chmod a+x $csh 2>/dev/null  
   else  #(!f csh)   
       echo -e '#!/bin/bash' >> $csh
       echo -e "\n$startup\n" >> $csh  
       dos2unix $csh 2>/dev/null; chmod a+x $csh 2>/dev/null  
fi 
dos2unix ~/custom.sh 2>/dev/null
chmod a+x ~/custom.sh 2>/dev/null
# -------------------------------------------------------------------- 
# REMOVER LINHA ANTIGA DA V34- CUSTOM.SH SE ENCONTRADA E O SISTEMA FOR AGORA V35+:
# ISSO DEVE AJUDAR COM VERSÕES ATUALIZADAS E 'OUTRAS INSTALAÇÕES' 
   if [[ "$(uname -a | grep "x86_64")" != "" ]] && [[ "$(uname -a | awk '{print $3}')" > "5.18.00" ]]; then
      remove="cat /userdata/system/configs/emulationstation/add_feat_os.cfg /userdata/system/configs/emulationstation/add_feat_switch.cfg"
      csh=/userdata/system/custom.sh
        if [[ -e "$csh" ]]; then
         tmp=/userdata/system/customsh.tmp
         rm $tmp 2>/dev/null
         nl=$(cat "$csh" | wc -l)
         l=1; while [[ "$l" -le "$nl" ]]; 
         do
            ln=$(cat "$csh" | sed ""$l"q;d")
               if [[ "$(echo "$ln" | grep "$remove")" != "" ]]; then :; else echo "$ln" >> "$tmp"; fi
            ((l++))
         done
         cp "$tmp" "$csh" 2>/dev/null
         rm "$tmp" 2>/dev/null
        fi
      es=/userdata/system/configs/emulationstation
      backup=/userdata/system/switch/extra/backup
      mkdir /userdata/system/switch 2>/dev/null
      mkdir /userdata/system/switch/extra 2>/dev/null
      mkdir /userdata/system/switch/extra/backup 2>/dev/null
      # REMOVER ARQUIVOS ANTIGOS ~/CONFIGS/EMULATIONSTATION/ se encontrados e o sistema estiver atualizado: 
      rm "$es/add_feat_switch.cfg" 2>/dev/null
   fi
# -------------------------------------------------------------------- 
# REMOVER ATUALIZADORES ANTIGOS 
rm /userdata/roms/ports/updateyuzu.sh 2>/dev/null 
rm /userdata/roms/ports/updateyuzuea.sh 2>/dev/null
rm /userdata/roms/ports/updateyuzuEA.sh 2>/dev/null 
rm /userdata/roms/ports/updateryujinx.sh 2>/dev/null
rm /userdata/roms/ports/updateryujinxavalonia.sh 2>/dev/null
# --------------------------------------------------------------------
# PUXAR AUTOMATICAMENTE AS ATUALIZAÇÕES MAIS RECENTES DE RECURSOS DOS EMULADORES / TAMBÉM ATUALIZAR ESTES ARQUIVOS: 
mkdir -p /userdata/system/switch/extra 2>/dev/null
mkdir -p /userdata/system/switch/configgen/generators/yuzu 2>/dev/null
mkdir -p /userdata/system/switch/configgen/generators/ryujinx 2>/dev/null
mkdir -p /userdata/system/configs/emulationstation 2>/dev/null
mkdir -p /userdata/system/configs/evmapy 2>/dev/null
url_switchkeys=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/configs/evmapy/switch.keys
url_es_features_switch=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/configs/emulationstation/es_features_switch.cfg
url_es_systems_switch=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/configs/emulationstation/es_systems_switch.cfg
url_switchlauncher=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/configgen/switchlauncher.py
url_GeneratorImporter=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/configgen/GeneratorImporter.py
url_ryujinxMainlineGenerator=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/configgen/generators/ryujinx/ryujinxMainlineGenerator.py
url_yuzuMainlineGenerator=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/configgen/generators/yuzu/yuzuMainlineGenerator.py
url_sshupdater=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/batocera-switch-sshupdater.sh
url_updater=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/batocera-switch-updater.sh
url_portsupdater=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/roms/ports/Switch%20Updater.sh
url_portsupdaterkeys=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/roms/ports/Switch%20Updater.sh.keys   
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/configs/evmapy/switch.keys" "$url_switchkeys"
   ###curl -sSf "$url_switchkeys" -o "/userdata/system/configs/evmapy/switch.keys"
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/configs/emulationstation/es_features_switch.cfg" "$url_es_features_switch"
   ###curl -sSf "$url_es_features_switch" -o "/userdata/system/configs/emulationstation/es_features_switch.cfg"
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/configs/emulationstation/es_systems_switch.cfg" "$url_es_systems_switch"
   ###curl -sSf "$url_es_systems_switch" -o "/userdata/system/configs/emulationstation/es_systems_switch.cfg"
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/configgen/switchlauncher.py" "$url_switchlauncher"
   ###curl -sSf "$url_switchlauncher" -o "/userdata/system/switch/configgen/switchlauncher.py"
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/configgen/GeneratorImporter.py" "$url_GeneratorImporter"
   ###curl -sSf "$url_GeneratorImporter" -o "/userdata/system/switch/configgen/GeneratorImporter.py"
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/configgen/generators/ryujinx/ryujinxMainlineGenerator.py" "$url_ryujinxMainlineGenerator"
   ###curl -sSf "$url_ryujinxMainlineGenerator" -o "/userdata/system/switch/configgen/generators/ryujinx/ryujinxMainlineGenerator.py"
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/configgen/generators/yuzu/yuzuMainlineGenerator.py" "$url_yuzuMainlineGenerator"
   ###curl -sSf "$url_yuzuMainlineGenerator" -o "/userdata/system/switch/configgen/generators/yuzu/yuzuMainlineGenerator.py"
      dos2unix "/userdata/system/configs/evmapy/switch.keys" 2>/dev/null
      dos2unix "/userdata/system/configs/emulationstation/es_features_switch.cfg" 2>/dev/null 
      dos2unix "/userdata/system/configs/emulationstation/es_systems_switch.cfg" 2>/dev/null
      dos2unix "/userdata/system/switch/configgen/switchlauncher.py" 2>/dev/null
      dos2unix "/userdata/system/switch/configgen/GeneratorImporter.py" 2>/dev/null
      dos2unix "/userdata/system/switch/configgen/generators/ryujinx/ryujinxMainlineGenerator.py" 2>/dev/null 
      dos2unix "/userdata/system/switch/configgen/generators/yuzu/yuzuMainlineGenerator.py" 2>/dev/null
      dos2unix "/userdata/system/switch/configgen/generators/yuzu/yuzuMainlineGenerator.py" 2>/dev/null
   # atualizar batocera-switch-sshupdater.sh
   ##wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/extra/batocera-switch-sshupdater.sh" "$url_sshupdater"
   ###curl -sSf "$url_sshupdater" -o "/userdata/system/switch/extra/batocera-switch-sshupdater.sh"
   ###dos2unix "/userdata/system/switch/extra/batocera-switch-sshupdater.sh" 2>/dev/null
   ###chmod a+x "/userdata/system/switch/extra/batocera-switch-sshupdater.sh" 2>/dev/null
   # atualizar batocera-switch-updater.sh
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/extra/batocera-switch-updater.sh" "$url_updater"
   ###curl -sSf "$url_updater" -o "/userdata/system/switch/extra/batocera-switch-updater.sh"
   dos2unix "/userdata/system/switch/extra/batocera-switch-updater.sh" 2>/dev/null
   chmod a+x "/userdata/system/switch/extra/batocera-switch-updater.sh" 2>/dev/null
   # atualizar ports Switch Updater.sh
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/roms/ports/Switch Updater.sh" "$url_portsupdater"
   ###curl -sSf "$url_portsupdater" -o "/userdata/roms/ports/Switch Updater.sh"
   dos2unix "/userdata/system/roms/ports/Switch Updater.sh" 2>/dev/null
   chmod a+x "/userdata/system/roms/ports/Switch Updater.sh" 2>/dev/null
   # atualizar ports Switch Updater.sh.keys
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/roms/ports/Switch Updater.sh.keys" "$url_portsupdaterkeys"
   ###curl -sSf "$url_portsupdaterkeys" -o "/userdata/roms/ports/Switch Updater.sh.keys"
   dos2unix "/userdata/system/roms/ports/Switch Updater.sh.keys" 2>/dev/null
   # obter batocera-switch-patcher.sh 
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/extra/batocera-switch-patcher.sh" "$url_patcher"
   ###curl -sSf "$url_patcher" -o "/userdata/system/switch/extra/batocera-switch-patcher.sh"
   dos2unix "/userdata/system/switch/extra/batocera-switch-patcher.sh" 2>/dev/null
   chmod a+x "/userdata/system/switch/extra/batocera-switch-patcher.sh" 2>/dev/null
# --------------------------------------------------------------------
# puxar todo o configgen para sincronizar todas as mudanças de autocontrolador: 
# -------------------------------------------------------------------- 
# PREENCHER /USERDATA/SYSTEM/SWITCH/CONFIGGEN
path=/userdata/system/switch/configgen
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/configgen
mkdir -p $path 2>/dev/null
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/GeneratorImporter.py" "$url/GeneratorImporter.py"
###curl -sSf "$url/GeneratorImporter.py" -o "$path/GeneratorImporter.py"
#wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/mapping.csv" "$url/mapping.csv"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/switchlauncher.py" "$url/switchlauncher.py"
###curl -sSf "$url/switchlauncher.py" -o "$path/switchlauncher.py"
####wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/switchlauncher_old.py" "$url/switchlauncher_old.py"
#####curl -sSf "$url/switchlauncher_old.py" -o "$path/switchlauncher_old.py"
# -------------------------------------------------------------------- 
# PREENCHER /USERDATA/SYSTEM/SWITCH/CONFIGGEN/GENERATORS
path=/userdata/system/switch/configgen/generators
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/configgen/generators
mkdir -p $path 2>/dev/null
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/__init__.py" "$url/__init__.py"
##curl -sSf "$url/__init__.py" -o "$path/__init__.py"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/Generator.py" "$url/Generator.py"
##curl -sSf "$url/Generator.py" -o "$path/Generator.py"
# -------------------------------------------------------------------- 
# PREENCHER /USERDATA/SYSTEM/SWITCH/CONFIGGEN/GENERATORS/YUZU
path=/userdata/system/switch/configgen/generators/yuzu
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/configgen/generators/yuzu
mkdir -p $path 2>/dev/null
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/__init__.py" "$url/__init__.py"
##curl -sSf "$url/__init__.py" -o "$path/__init__.py"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/yuzuMainlineGenerator.py" "$url/yuzuMainlineGenerator.py"
##curl -sSf "$url/yuzuMainlineGenerator.py" -o "$path/yuzuMainlineGenerator.py"
# -------------------------------------------------------------------- 
# PREENCHER /USERDATA/SYSTEM/SWITCH/CONFIGGEN/GENERATORS/RYUJINX
path=/userdata/system/switch/configgen/generators/ryujinx
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/configgen/generators/ryujinx
mkdir -p $path 2>/dev/null
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/__init__.py" "$url/__init__.py"
##curl -sSf "$url/__init__.py" -o "$path/__init__.py"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/ryujinxMainlineGenerator.py" "$url/ryujinxMainlineGenerator.py"
##curl -sSf "$url/ryujinxMainlineGenerator.py" -o "$path/ryujinxMainlineGenerator.py"
# -------------------------------------------------------------------- 
# PREENCHER /USERDATA/SYSTEM/SWITCH/CONFIGGEN/SDL2
path=/userdata/system/switch/configgen/sdl2
mkdir -p $path 2>/dev/null
cd $path
if [[ ! -f "/userdata/system/switch/configgen/sdl2/sdl2.zip" ]]; then 
rm -rf /userdata/system/switch/configgen/sdl2/sdl2.zip 2>/dev/null
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/configgen/sdl2/sdl2.zip" "$extraurl/sdl2.zip"
##curl -sSf "$extraurl/sdl2.zip" -o "/userdata/system/switch/configgen/sdl2/sdl2.zip"
unzip -oq /userdata/system/switch/configgen/sdl2/sdl2.zip
else 
   if [[ "$(wc -c "/userdata/system/switch/configgen/sdl2/sdl2.zip" | awk '{print $1}')" < "100000" ]]; then 
   rm -rf /userdata/system/switch/configgen/sdl2/sdl2.zip 2>/dev/null
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/configgen/sdl2/sdl2.zip" "$extraurl/sdl2.zip"
   ##curl -sSf "$extraurl/sdl2.zip" -o "/userdata/system/switch/configgen/sdl2/sdl2.zip"
   unzip -oq /userdata/system/switch/configgen/sdl2/sdl2.zip
   fi
fi 
# passe adicional para pessoas que têm problemas para conectar ao github
   function get() {
      file="$1"
      path=/userdata/system/switch/configgen/sdl2
      url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/configgen/sdl2
         mkdir -p $path 2>/dev/null
            if [[ ! -e "$path/$file" ]]; then
               cd $path
               wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/$file" "$url/$file"
               ###curl -sSf "$url/$file" -o "$path/$file"
            else 
               if [[ "$(wc -c "$path/$file" | awk '{print $1}')" < "5" ]]; then 
               cd $path
               wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/$file" "$url/$file"
               fi
            fi
   }
      get __init__.py
      get _internal.py
      get _sdl_init.py
      get audio.py
      get blendmode.py
      get clipboard.py
      get cpuinfo.py
      get dll.py
      get endian.py
      get error.py
      get events.py
      get filesystem.py
      get gamecontroller.py
      get gesture.py
      get guid.py
      get haptic.py
      get hidapi.py
      get hints.py
      get joystick.py
      get keyboard.py
      get keycode.py
      get loadso.py
      get locale.py
      get log.py
      get messagebox.py
      get metal.py
      get misc.py
      get mouse.py
      get pixels.py
      get platform.py
      get power.py
      get rect.py
      get render.py
      get rwops.py
      get scancode.py
      get sdlgfx.py
      get sdlimage.py
      get sdlmixer.py
      get sdlttf.py
      get sensor.py
      get shape.py
      get stdinc.py
      get surface.py
      get syswm.py
      get timer.py
      get touch.py
      get version.py
      get video.py
      get vulkan.py
   chmod 777 $path/* 2>/dev/null
cd ~/
# -------------------------------------------------------------------- 
# OBTER RYUJINX 942 libSDL2.so para processamento atualizado de controles 
rm /userdata/system/switch/extra/batocera-switch-libSDL2.so 2>/dev/null
mkdir -p /userdata/system/switch/extra/sdl 2>/dev/null
sdl=/userdata/system/switch/extra/sdl/libSDL2.so
sdlurl=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/batocera-switch-libSDL2.so
   if [[ ! -e "$sdl" ]]; then 
      wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$sdl" "$sdlurl"
      ###curl -sSf "$sdlurl" -o "$sdl"
   else 
      if [[ "$(md5sum $sdl | awk '{print $1}')" != "dc4a162f60622b04813fbf1756419c89" ]] || [[ "$(wc -c $sdl | awk '{print $1}')" != "2493584" ]]; then 
         wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$sdl" "$sdlurl"
         ###curl -sSf "$sdlurl" -o "$sdl"
      fi 
   fi 
      chmod a+x "$sdl" 2>/dev/null 
# --------------------------------------------------------------------
# REMOVER PROMPT DE SAÍDA DO YUZU NA NOVA VERSÃO
if [[ -e /userdata/system/configs/yuzu/qt-config.ini ]]; then 
   sed -i 's,confirmStop=0,confirmStop=2,g' /userdata/system/configs/yuzu/qt-config.ini 2>/dev/null
   sed -i 's,confirmStop\\default=true,confirmStop\\default=false,g' /userdata/system/configs/yuzu/qt-config.ini 2>/dev/null
fi
# --------------------------------------------------------------------
# OBTER ÍCONES DO ATUALIZADOR GUI
urldir="https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra"
icon1url="http://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/icon_updater.png"
icon2url="http://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/icon_loading.png"
icon1=icon_updater.png ; icon2=icon_loading.png ; dest=/userdata/system/switch/extra ; mkdir -p $dest 2>/dev/null
      wget -q --tries=10 -O "$dest/$icon1" "$urldir/$icon1"
      ##curl -sSf "$urldir/$icon1" -o "/userdata/system/switch/extra/icon_updater.png"
      wget -q --tries=10 -O "$dest/$icon2" "$urldir/$icon2"
      ##curl -sSf "$urldir/$icon2" -o "/userdata/system/switch/extra/icon_loading.png"
# -------------------------------------------------------------------- 
# OBTER TRADUÇÕES
path=/userdata/system/switch/extra/translations
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/translations
mkdir -p $path 2>/dev/null
mkdir -p $path/en_US 2>/dev/null
mkdir -p $path/fr_FR 2>/dev/null
   english=en_US/es_features_switch.cfg
   french=fr_FR/es_features_switch.cfg
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/$english" "$url/$english"
   wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/$french" "$url/$french"
   dos2unix "$path/$english" 2>/dev/null
   dos2unix "$path/$french" 2>/dev/null
# OBTER TRADUTOR
translator=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/batocera-switch-translator.sh
path=/userdata/system/switch/extra/batocera-switch-translator.sh
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path" "$translator"
   dos2unix "$path" 2>/dev/null
   chmod 777 "$path" 2>/dev/null
# --------------------------------------------------------------------
# LIMPAR TEMP & COOKIE:
rm -rf /userdata/system/switch/extra/downloads 2>/dev/null
rm /userdata/system/switch/extra/display.settings 2>/dev/null
rm /userdata/system/switch/extra/updater.settings 2>/dev/null

echo -e "${GREEN}❯❯❯ ${F}CONCLUÍDO ${T}"
sleep 2

}
export -f post-install
#
######################################################################
#\
if [[ "$MODE" != "CONSOLE" ]]; then 
# incluir saída de exibição: 
   tput=/userdata/system/switch/extra/batocera-switch-tput
   libtinfo=/userdata/system/switch/extra/batocera-switch-libtinfo.so.6
   mkdir /userdata/system/switch 2>/dev/null; mkdir /userdata/system/switch/extra 2>/dev/null
      if [[ ( -e "$tput" && "$(wc -c "$tput" | awk '{print $1}')" < "444" ) || ( ! -e "$tput" ) ]]; then
         rm "$tput" 2>/dev/null
         wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O /userdata/system/switch/extra/batocera-switch-tput https://github.com/uureel/batocera-switch/raw/main/system/switch/extra/batocera-switch-tput
         ##curl -sSf "https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/batocera-switch-tput" -o "/userdata/system/switch/extra/batocera-switch-tput"
      fi
      if [[ ( -e "$libtinfo" && "$(wc -c "$libtinfo" | awk '{print $1}')" < "444" ) || ( ! -e "$libtinfo" ) ]]; then
         rm "$libtinfo" 2>/dev/null
         wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O /userdata/system/switch/extra/batocera-switch-libtinfo.so.6 https://github.com/uureel/batocera-switch/raw/main/system/switch/extra/batocera-switch-libtinfo.so.6
         ##curl -sSf "https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/batocera-switch-libtinfo.so.6" -o "/userdata/system/switch/extra/batocera-switch-libtinfo.so.6"
      fi
   chmod a+x "$tput" 2>/dev/null
   if [[ -e "/lib/libtinfo.so.6" ]] || [[ -e "/usr/lib/libtinfo.so.6" ]]; then 
   :
   else
   cp "$libtinfo" "/usr/lib/libtinfo.so.6" 2>/dev/null
   fi
# 
      function get-fontsize {
         cfg=/userdata/system/switch/extra/display.cfg
            rm /tmp/cols 2>/dev/null
            killall -9 /tmp/batocera-switch-updater 2>/dev/null
            DISPLAY=:0.0 /tmp/batocera-switch-updater -maximized -fg black -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "unset COLUMNS & /userdata/system/switch/extra/batocera-switch-tput cols >> /tmp/cols 2>/dev/null" 2>/dev/null
            killall -9 /tmp/batocera-switch-updater 2>/dev/null
         res=$(xrandr | grep " connected " | awk '{print $3}' | cut -d x -f1)
         columns=$(cat /tmp/cols); echo "$res=$columns" >> "$cfg"
         cols=$(cat "$cfg" | tail -n 1 | cut -d "=" -f2 2>/dev/null) 2>/dev/null
         TEXT_SIZE=$(bc <<<"scale=0;$cols/11" 2>/dev/null) 2>/dev/null
      }
      export -f get-fontsize
##################################
get-fontsize 2>/dev/null
#
# garantir tamanho da fonte: 
cfg=/userdata/system/switch/extra/display.cfg
cols=$(cat "$cfg" | tail -n 1 | cut -d "=" -f2 2>/dev/null) 2>/dev/null
colres=$(cat "$cfg" | tail -n 1 | cut -d "=" -f1 2>/dev/null) 2>/dev/null
res=$(xrandr | grep " connected " | awk '{print $3}' | cut -d x -f1)
fallback=9 
#
#####
   if [[ -e "$cfg" ]] && [[ "$cols" != "80" ]]; then 
      if [[ "$colres" = "$res" ]]; then
         TEXT_SIZE=$(bc <<<"scale=0;$cols/11" 2>/dev/null) 2>/dev/null
      fi
      #|
      if [[ "$colres" != "$res" ]]; then
         rm "$cfg" 2>/dev/null
            try=1
            until [[ "$cols" != "80" ]] 
            do
            get-fontsize 2>/dev/null
            cols=$(cat "$cfg" | tail -n 1 | cut -d "=" -f2 2>/dev/null) 2>/dev/null
            try=$(($try+1)); if [[ "$try" -ge "10" ]]; then TEXT_SIZE=$fallback; cols=1; fi
            done 
            if [[ "$cols" != "1" ]]; then TEXT_SIZE=$(bc <<<"scale=0;$cols/11" 2>/dev/null) 2>/dev/null; fi
      fi
   # 
   else
   # 
      get-fontsize 2>/dev/null
      cols=$(cat "$cfg" | tail -n 1 | cut -d "=" -f2 2>/dev/null) 2>/dev/null
         try=1
         until [[ "$cols" != "80" ]] 
         do
            get-fontsize 2>/dev/null
            cols=$(cat "$cfg" | tail -n 1 | cut -d "=" -f2 2>/dev/null) 2>/dev/null
            try=$(($try+1)); if [[ "$try" -ge "10" ]]; then TEXT_SIZE=$fallback; cols=1; fi
         done 
         if [[ "$cols" != "1" ]]; then TEXT_SIZE=$(bc <<<"scale=0;$cols/11" 2>/dev/null) 2>/dev/null; fi
         if [ "$TEXT_SIZE" = "" ]; then TEXT_SIZE=$fallback; fi
   fi    #
   ##### #
         if [[ ( -e "/tmp/updater-textsize" && "$(cat "/tmp/updater-textsize" | grep "AUTO")" != "") || ( -e "/tmp/updater-textsize" && "$(cat "/tmp/updater-textsize" | grep "auto")" != "" ) ]]; then 
            TEXT_SIZE=$TEXT_SIZE
         else 
            TEXT_SIZE=$(cat "/tmp/updater-textsize")
         fi
         TEXT_SIZE=$(bc <<< "$TEXT_SIZE/1")
         # ###################################################################
         # 
         ## EXECUTAR O ATUALIZADOR: ------------------------------------------------- 
            if [[ "$MODE" = "DISPLAY" ]]; then 
               if [[ "$ANIMATION" = "YES" ]]; then 
                  DISPLAY=:0.0 unclutter-remote -h && DISPLAY=:0.0 /tmp/batocera-switch-updater -maximized -fs "$TEXT_SIZE" -fg black -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0 cvlc -f --no-audio --no-video-title-show --no-mouse-events --no-keyboard-events --no-repeat /userdata/system/switch/extra/loader.mp4 2>/dev/null & sleep 3.69 && killall -9 vlc && DISPLAY=:0.0 batocera_update_switch && DISPLAY=:0.0 post-install"
               else 
                  DISPLAY=:0.0 unclutter-remote -h && DISPLAY=:0.0 /tmp/batocera-switch-updater -maximized -fs "$TEXT_SIZE" -fg black -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0 batocera_update_switch && post-install"
               fi 
            fi 
fi 
#/ 
#################################################################################################################################
            if [[ "$MODE" = "CONSOLE" ]]; then 
                  DISPLAY=:0.0 batocera_update_switch console && DISPLAY=:0.0 post-install
            fi 
#################################################################################################################################
wait
   # --- \ restaurar arquivo de config do usuário para o atualizador se executando instalação/atualização limpa do instalador switch 
   if [[ -e /tmp/.userconfigfile ]]; then 
      cp /tmp/.userconfigfile /userdata/system/switch/CONFIG.txt 2>/dev/null
      rm /tmp/.userconfigfile 2>/dev/null
   fi 
   # --- / 
sysctl -w net.ipv6.conf.default.disable_ipv6=0 1>/dev/null 2>/dev/null
sysctl -w net.ipv6.conf.all.disable_ipv6=0 1>/dev/null 2>/dev/null
sleep 2 && killall -9 batocera-switch-updater 2>/dev/null && curl http://127.0.0.1:1234/reloadgames && exit 0; exit 1
#################################################################################################################################