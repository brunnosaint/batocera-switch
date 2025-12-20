#!/usr/bin/env bash 
# INSTALADOR BATOCERA.PRO
######################################################################
#--------------------------------------------------------------------- 
APPNAME="EMULAÇÃO SWITCH PARA v39/v40" 
ORIGIN="github.com/brunnosaint/batocera-switch" 
#---------------------------------------------------------------------
######################################################################
ORIGIN="${ORIGIN^^}"
extra=/userdata/system/switch/extra 
mkdir /userdata/system/switch 2>/dev/null 
mkdir /userdata/system/switch/extra 2>/dev/null 
sysctl -w net.ipv6.conf.default.disable_ipv6=1 1>/dev/null 2>/dev/null
sysctl -w net.ipv6.conf.all.disable_ipv6=1 1>/dev/null 2>/dev/null
#/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
# --------------------------------------------------------------------
#\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\   
function batocera-pro-installer {
APPNAME=$1
ORIGIN=$2
# --------------------------------------------------------------------
# -- cores: 
###########################
X='\033[0m'               # / resetar cor
W='\033[0;37m'            # branco
#-------------------------#
RED='\033[1;31m'          # vermelho
BLUE='\033[1;34m'         # azul
GREEN='\033[1;32m'        # verde
PURPLE='\033[1;35m'       # roxo
DARKRED='\033[0;31m'      # vermelho escuro
DARKBLUE='\033[0;34m'     # azul escuro
DARKGREEN='\033[0;32m'    # verde escuro
DARKPURPLE='\033[0;35m'   # roxo escuro
###########################
# -- tema de exibição:
L=$W
T=$W
R=$RED
B=$BLUE
G=$GREEN
P=$PURPLE
W=$X
# --------------------------------------------------------------------
clear
echo
echo
echo
echo -e "${X}${X}$APPNAME${X} INSTALADOR ${X}"
echo
echo
echo
sleep 0.33

clear
echo
echo
echo
echo -e "${X}${X}$APPNAME${X} INSTALADOR ${X}"
echo
echo
echo
sleep 0.33

clear
echo
echo
echo -e "${X}- - - - - - - - -"
echo -e "${X}${X}$APPNAME${X} INSTALADOR ${X}"
echo -e "${X}- - - - - - - - -"
echo
echo
sleep 0.33
clear

echo
echo -e "${X}- - - - - - - - -"
echo
echo -e "${X}${X}$APPNAME${X} INSTALADOR ${X}"
echo 
echo -e "${X}- - - - - - - - -"
sleep 0.33

clear
echo -e "${X}- - - - - - - - -"
echo 
echo 
echo -e "${X}${X}$APPNAME${X} INSTALADOR ${X}"
echo 
echo 
echo -e "${X}- - - - - - - - -"
sleep 0.33

clear
echo
echo
echo 
echo -e "${X}${X}$APPNAME${X} INSTALADOR ${X}"
echo 
echo 
echo
sleep 0.33

echo -e "${X}INSTALANDO $APPNAME NO BATOCERA"
echo -e "${X}USANDO $ORIGIN"
echo 
echo
echo
sleep 3
# --------------------------------------------------------------------
# -- verificar sistema antes de continuar
if [[ "$(uname -a | grep "x86_64")" != "" ]]; then 
:
else
echo
echo -e "${X}ERRO: SISTEMA NÃO SUPORTADO"
echo -e "${X}VOCÊ PRECISA DO BATOCERA X86_64${X}"
echo
sleep 5
exit 0
fi
# --------------------------------------------------------------------
echo -e "${X}POR FAVOR, AGUARDE${X} . . ." 
# -------------------------------------------------------------------- 
# PRESERVAR ARQUIVO DE CONFIGURAÇÃO 
cfg=/userdata/system/switch/CONFIG.txt 
if [[ -f "$cfg" ]]; then 
      link_defaultconfig=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/batocera-switch-config.txt
      wget -q --no-check-certificate --no-cache --no-cookies -O "/tmp/.CONFIG.txt" "$link_defaultconfig"
         currentver=$(cat "$cfg" | grep "(ver " | head -n1 | sed 's,^.*(ver ,,g' | cut -d ")" -f1)
            if [[ "$currentver" = "" ]]; then currentver=1.0.0; fi
         latestver=$(cat "/tmp/.CONFIG.txt" | grep "(ver " | head -n1 | sed 's,^.*(ver ,,g' | cut -d ")" -f1)
            if [[ "$latestver" > "$currentver" ]]; then 
               cp /tmp/.CONFIG.txt $cfg 2>/dev/null
               echo -e "\n~/switch/CONFIG.txt FOI ATUALIZADO!\n"
            fi
   cp $cfg /tmp/.userconfigfile 2>/dev/null
fi
# -------------------------------------------------------------------- 
# LIMPAR ARQUIVOS ANTIGOS 
rm /userdata/system/configs/emulationstation/add_feat_switch.cfg 2>/dev/null
rm /userdata/system/configs/emulationstation/es_features.cfg 2>/dev/null
rm /userdata/system/switch/configgen/controllersConfig.py 2>/dev/null
rm /userdata/system/switch/configgen/batoceraFiles.py 2>/dev/null
rm /userdata/system/switch/configgen/evmapy.py 2>/dev/null
# -------------------------------------------------------------------- 
# CRIAR PASTAS NECESSÁRIAS
mkdir /userdata/roms/switch 2>/dev/null
mkdir /userdata/roms/ports 2>/dev/null
mkdir /userdata/roms/ports/images 2>/dev/null
mkdir /userdata/bios/switch 2>/dev/null
mkdir /userdata/bios/switch/firmware 2>/dev/null
mkdir /userdata/system/switch 2>/dev/null
mkdir /userdata/system/switch/extra 2>/dev/null
mkdir /userdata/system/switch/configgen 2>/dev/null
mkdir /userdata/system/switch/configgen/generators 2>/dev/null
mkdir /userdata/system/switch/configgen/generators/suyu 2>/dev/null
mkdir /userdata/system/switch/configgen/generators/yuzu 2>/dev/null
mkdir /userdata/system/switch/configgen/generators/ryujinx 2>/dev/null
mkdir /userdata/system/configs 2>/dev/null
mkdir /userdata/system/configs/evmapy 2>/dev/null
mkdir /userdata/system/configs/emulationstation 2>/dev/null

# -------------------------------------------------------------------- 
# PREENCHER /USERDATA/SYSTEM/SWITCH/EXTRA
path=/userdata/system/switch/extra
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/batocera-config-ryujinx" "$url/batocera-config-ryujinx"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/batocera-config-ryujinx-avalonia" "$url/batocera-config-ryujinx-avalonia"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/batocera-config-yuzu" "$url/batocera-config-yuzu"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/batocera-config-yuzuEA" "$url/batocera-config-yuzuEA"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/batocera-switch-libselinux.so.1" "$url/batocera-switch-libselinux.so.1"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/batocera-switch-libthai.so.0.3" "$url/batocera-switch-libthai.so.0.3"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/batocera-switch-libtinfo.so.6" "$url/batocera-switch-libtinfo.so.6"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/batocera-switch-sshupdater.sh" "$url/batocera-switch-sshupdater.sh"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/batocera-switch-tar" "$url/batocera-switch-tar"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/batocera-switch-tput" "$url/batocera-switch-tput"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/batocera-switch-updater40.sh" "$url/batocera-switch-updater40.sh"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/icon_ryujinx.png" "$url/icon_ryujinx.png"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/icon_ryujinxg.png" "$url/icon_ryujinxg.png"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/icon_yuzu.png" "$url/icon_yuzu.png"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/libthai.so.0.3.1" "$url/libthai.so.0.3.1"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/ryujinx-avalonia.png" "$url/ryujinx-avalonia.png"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/ryujinx.png" "$url/ryujinx.png"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/yuzu.png" "$url/yuzu.png"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/yuzuEA.png" "$url/yuzuEA.png"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/batocera-config-suyu" "$url/batocera-config-suyu"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/batocera-config-suyuQL" "$url/batocera-config-suyuQL"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/suyu.png" "$url/suyu.png"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/suyu-config.desktop" "$url/suyu-config.desktop"
# -------------------------------------------------------------------- 
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/userdata/system/switch/CONFIG.txt" "https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/batocera-switch-config.txt"
# -------------------------------------------------------------------- 
# PREENCHER GENERATORS (RYUJINX, SUYU, YUZU, etc.)
path=/userdata/system/switch/configgen/generators/ryujinx
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/configgen40/generators/ryujinx
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/__init__.py" "$url/__init__.py"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/ryujinxMainlineGenerator.py" "$url/ryujinxMainlineGenerator.py"

path=/userdata/system/switch/configgen/generators/suyu
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/configgen40/generators/suyu
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/suyuGenerator.py" "$url/suyuGenerator.py"

path=/userdata/system/switch/configgen/generators/yuzu
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/configgen40/generators/yuzu
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/__init__.py" "$url/__init__.py"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/yuzuMainlineGenerator.py" "$url/yuzuMainlineGenerator.py"

path=/userdata/system/switch/configgen/generators
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/configgen40/generators
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/__init__.py" "$url/__init__.py"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/Generator.py" "$url/Generator.py"

path=/userdata/system/switch/configgen
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/configgen40
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/GeneratorImporter.py" "$url/GeneratorImporter.py"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/switchlauncher.py" "$url/switchlauncher.py"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/configgen-defaults.yml" "$url/configgen-defaults.yml"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/configgen-defaults-arch.yml" "$url/configgen-defaults-arch.yml"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/Emulator.py" "$url/Emulator.py"

path=/userdata/system/configs/emulationstation
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/configgen40/emulationstation40
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/es_features_switch.cfg" "$url/es_features_switch.cfg"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/es_systems_switch.cfg" "$url/es_systems_switch.cfg"

path=/userdata/system/configs/evmapy
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/configs/evmapy
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/switch.keys" "$url/switch.keys"

path=/userdata/roms/ports 
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/roms/ports
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/Switch Updater40.sh" "$url/Switch Updater40.sh"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/Switch Updater40.sh.keys" "$url/Switch Updater40.sh.keys"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/Suyu Qlauncher.sh" "$url/Suyu Qlauncher.sh"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/Suyu Qlauncher.sh.keys" "$url/Suyu Qlauncher.sh.keys"

path=/userdata/roms/ports/images
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/roms/ports/images
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/Switch Updater-boxart.png" "$url/Switch Updater-boxart.png"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/Switch Updater-cartridge.png" "$url/Switch Updater-cartridge.png"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/Switch Updater-mix.png" "$url/Switch Updater-mix.png"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/Switch Updater-screenshot.png" "$url/Switch Updater-screenshot.png"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/Switch Updater-wheel.png" "$url/Switch Updater-wheel.png"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/suyu-boxart.png" "$url/suyu-boxart.png"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/suyu-logo.png" "$url/suyu-logo.png"
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/suyu-screenshot.png" "$url/suyu-screenshot.png"

path=/userdata/system/.local/share/applications
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra
wget --show-progress --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/suyu-config.desktop" "$url/suyu-config.desktop"

path=/userdata/roms/switch
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/roms/switch
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/_info.txt" "$url/_info.txt"

path=/userdata/bios/switch
url=https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/bios/switch
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "$path/_info.txt" "$url/_info.txt"

# REMOVER UPDATERS ANTIGOS
rm /userdata/roms/ports/updateyuzu.sh 2>/dev/null 
rm /userdata/roms/ports/updateyuzuea.sh 2>/dev/null
rm /userdata/roms/ports/updateyuzuEA.sh 2>/dev/null 
rm /userdata/roms/ports/updateryujinx.sh 2>/dev/null
rm /userdata/roms/ports/updateryujinxavalonia.sh 2>/dev/null

# PERMISSÕES
dos2unix /userdata/system/switch/extra/*.sh 2>/dev/null
dos2unix /userdata/system/switch/extra/batocera-config* 2>/dev/null
chmod a+x /userdata/system/switch/extra/*.sh 2>/dev/null
chmod a+x /userdata/system/switch/extra/batocera-config* 2>/dev/null
chmod a+x /userdata/system/switch/extra/batocera-switch-lib* 2>/dev/null
chmod a+x /userdata/system/switch/extra/*.desktop 2>/dev/null
chmod a+x /userdata/system/.local/share/applications/*.desktop 2>/dev/null

echo -e "${X} > INSTALADO COM SUCESSO${X}" 
sleep 1
echo
echo
echo

X='\033[0m'
echo -e "${X}CARREGANDO ATUALIZADOR SWITCH . . .${X}" 
echo -e "${X} "
rm -rf /userdata/system/switch/extra/installation 2>/dev/null
rm /tmp/batocera-switch-updater40.sh 2>/dev/null 
mkdir -p /tmp 2>/dev/null
wget -q --tries=10 --no-check-certificate --no-cache --no-cookies -O "/tmp/batocera-switch-updater40.sh" "https://raw.githubusercontent.com/brunnosaint/batocera-switch/main/system/switch/extra/batocera-switch-updater40.sh" 
sed -i 's,MODE=DISPLAY,MODE=CONSOLE,g' /tmp/batocera-switch-updater40.sh 2>/dev/null
dos2unix /tmp/batocera-switch-updater40.sh 2>/dev/null 
chmod a+x /tmp/batocera-switch-updater40.sh 2>/dev/null 
/tmp/batocera-switch-updater40.sh CONSOLE 
sleep 0.1 
echo "OK" >> /userdata/system/switch/extra/installation
sleep 0.1

if [[ -e /tmp/.userconfigfile ]]; then 
   cp /tmp/.userconfigfile /userdata/system/switch/CONFIG.txt 2>/dev/null
fi 
} 
export -f batocera-pro-installer 2>/dev/null 
# --------------------------------------------------------------------
batocera-pro-installer "$APPNAME" "$ORIGIN" 
# --------------------------------------------------------------------
sysctl -w net.ipv6.conf.default.disable_ipv6=0 1>/dev/null 2>/dev/null
sysctl -w net.ipv6.conf.all.disable_ipv6=0 1>/dev/null 2>/dev/null
X='\033[0m'

if [[ -e /userdata/system/switch/extra/installation ]]; then
    rm /userdata/system/switch/extra/installation 2>/dev/null
    clear
    echo 
    echo -e "   ${BLUE}INSTALADOR POR ${BLUE}"
    echo -e "   ${GREEN}brunnosaint ${GREEN}"
    echo -e "   ${X}$APPNAME INSTALADO COM SUCESSO${X}" 
    echo 
    echo 
    echo -e "   ${PURPLE}INFORMAÇÃO IMPORTANTE! ${PURPLE}"
    echo -e "   ${PURPLE}O /userdata PRECISA ESTAR EM EXT4 ou BTRFS para a emulação Switch funcionar! ${PURPLE}"
    echo -e "   ${PURPLE}NÃO DAREMOS SUPORTE SE VOCÊ NÃO ESTIVER EM EXT4/BTRFS! ${PURPLE}"
    echo -e "   ${PURPLE}Se você já está em BTRFS ou EXT4, pode ignorar esta mensagem ${PURPLE}"
    echo 
    echo -e "   ${X}SE A INSTALAÇÃO/DOWNLOAD FALHAR${X}"
    echo -e "   ${X}> Coloque manualmente o AppImage/tar/zip em /userdata/system/switch/appimages${X}" 
    echo -e "   ${X}> Pacote de arquivos disponível aqui: ${X}" 
    echo -e "   ${GREEN}> https://1fichier.com/?8furupg6hic0booljbmy ${GREEN}" 
    echo -e "   ${X}> Depois disso, abra o SWITCH UPDATER em PORTS ${X}" 
    echo
    echo
    echo -e "   ${X}-------------------------------------------------------------------${X}"
    echo -e "   ${X}Coloque suas keys em /userdata/bios/switch/${X}" 
    echo -e "   ${X}Firmware (*.nca) em /userdata/bios/switch/firmware/${X}" 
    echo
    echo -e "   ${X}-------------------------------------------------------------------${X}"
    echo -e "   ${X}EM CASO DE PROBLEMAS COM CONTROLE:${X}"
    echo 
    echo -e "   ${X}2) Use [autocontroller = off] nas configurações avançadas & ${X}"
    echo -e "   ${X}   configure o controle manualmente em F1 → Aplicações ${X}"
    echo
    echo -e "   ${X}-------------------------------------------------------------------${X}"
    echo 
    echo -e "   ${GREEN}RECARREGUE SUA LISTA DE JOGOS E BOM DIVERSÃO!${GREEN}" 
    echo 
    echo -e "   ${GREEN}Esta janela fechará automaticamente em 10 segundos...${X}"
    sleep 10
    curl http://127.0.0.1:1234/reloadgames
    exit 0
else
    clear 
    echo 
    echo 
    echo -e "   ${X}Parece que a instalação falhou :(${X}" 
    echo
    echo -e "   ${X}Tente executar o script novamente...${X}" 
    echo
    echo
    echo -e "   ${X}Se continuar falhando, tente instalar com este comando:${X}"
    echo
    echo -e "   ${X}cd /userdata ; wget -O s batocera.pro/s ; chmod 777 s ; ./s ${X}"
    echo 
    echo 
    sleep 5
    exit 0
fi