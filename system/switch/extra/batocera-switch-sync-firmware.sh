#!/bin/bash
#   //=================================//
#  //  batocera-switch sync firmware  //
# //=================================//
# 
# Script para sincronizar automaticamente o firmware do Switch entre os emuladores
# Pastas envolvidas:
# - Ryujinx: /userdata/system/configs/Ryujinx/bis/system/Contents/registered
# - Yuzu/Sudachi/etc.: /userdata/system/configs/yuzu/nand/system/Contents/registered
# - BIOS (pasta principal recomendada): /userdata/bios/switch/firmware
#
# O script detecta qual pasta tem o firmware mais recente/completo e copia para as outras.
# Critérios: data do arquivo mais recente, tamanho da pasta e número de arquivos.

# Definir caminhos das pastas de firmware
fr=/userdata/system/configs/Ryujinx/bis/system/Contents/registered      # Ryujinx
fy=/userdata/system/configs/yuzu/nand/system/Contents/registered        # Yuzu/Sudachi/Citron/etc.
fs=/userdata/bios/switch/firmware                                       # BIOS (pasta principal)

mkdir -p $fr 2>/dev/null
mkdir -p $fy 2>/dev/null
mkdir -p $fs 2>/dev/null

diag=0  # Modo diagnóstico (mude para 1 se quiser ver variáveis no final)

#
#\------------\ 
# \------------\ 
# Preparar verificações iniciais (flags para indicar se a pasta parece válida)
cr=1; cy=1; cs=1
#
# Baixar/Atualizar ferramenta 'stat' personalizada (versão compatível do Batocera-Switch)
if [[ ! -e /userdata/system/switch/extra/batocera-switch-stat ]]; then 
    url_stat=https://github.com/brunnosaint/batocera-switch/raw/main/system/switch/extra/batocera-switch-stat
    wget -q --no-check-certificate --no-cache --no-cookies -O /userdata/system/switch/extra/batocera-switch-stat $url_stat
elif [[ "$(wc -c /userdata/system/switch/extra/batocera-switch-stat | awk '{print $1}')" < "90000" ]]; then 
    url_stat=https://github.com/brunnosaint/batocera-switch/raw/main/system/switch/extra/batocera-switch-stat
    wget -q --no-check-certificate --no-cache --no-cookies -O /userdata/system/switch/extra/batocera-switch-stat $url_stat
fi 
chmod a+x /userdata/system/switch/extra/batocera-switch-stat 2>/dev/null
#
# Verificar arquivo .nca mais recente em cada pasta (para data de modificação)
rf=$(ls $fr -Art | grep ".nca" | tail -n 1)
yf=$(ls $fy -Art | grep ".nca" | tail -n 1)
sf=$(ls $fs -Art | grep ".nca" | tail -n 1)

if [[ "$rf" = "" ]]; then cr=0; else dr=$(/userdata/system/switch/extra/batocera-switch-stat -c "%Y" $fr/$rf 2>/dev/null); fi
if [[ "$yf" = "" ]]; then cy=0; else dy=$(/userdata/system/switch/extra/batocera-switch-stat -c "%Y" $fy/$yf 2>/dev/null); fi
if [[ "$sf" = "" ]]; then cs=0; else ds=$(/userdata/system/switch/extra/batocera-switch-stat -c "%Y" $fs/$sf 2>/dev/null); fi
#
# Verificar tamanho da pasta (em KB, deve ser > ~200MB para ser considerado válido)
sr=$(du -Hs $fr | awk '{print $1}')
sy=$(du -Hs $fy | awk '{print $1}')
ss=$(du -Hs $fs | awk '{print $1}')
if [[ "$sr" -le "200000" ]]; then cr=0; fi
if [[ "$sy" -le "200000" ]]; then cy=0; fi
if [[ "$ss" -le "200000" ]]; then cs=0; fi
#
# Verificar número de arquivos (deve ter mais de ~200 arquivos .nca para ser válido)
nr=$(find $fr -type f | wc -l)
ny=$(find $fy -type f | wc -l)
ns=$(find $fs -type f | wc -l)
if [[ "$nr" -le "200" ]]; then cr=0; fi
if [[ "$ny" -le "200" ]]; then cy=0; fi
if [[ "$ns" -le "200" ]]; then cs=0; fi
# /------------/ 
#/------------/ 
# 
# ---
#
# Determinar qual pasta tem o firmware mais atual (baseado na data do arquivo mais recente)
if [[ "$dr" != "" ]] && [[ "$dr" -ge "$dy" ]] && [[ "$dr" -ge "$ds" ]]; then f=r; fi  # Ryujinx mais novo
if [[ "$dy" != "" ]] && [[ "$dy" -ge "$dr" ]] && [[ "$dy" -ge "$ds" ]]; then f=y; fi  # Yuzu mais novo
if [[ "$ds" != "" ]] && [[ "$ds" -ge "$dr" ]] && [[ "$ds" -ge "$dy" ]]; then f=s; fi  # BIOS mais novo
#
# ---
#
# Sincronizar a partir da pasta BIOS (/userdata/bios/switch/firmware) se for a mais atual
if [[ "$f" = "s" ]]; then
	if [[ "$ds" > "$dr" ]]; then  
		rm -rf "$fr/"* 2>/dev/null
		rsync -au --delete $fs/ $fr/ 2>/dev/null & 
		wait 
	fi
	if [[ "$ds" > "$dy" ]]; then  
		rm -rf "$fy/"* 2>/dev/null
		rsync -au --delete $fs/ $fy/ 2>/dev/null & 
		wait 
	fi
	# Verificação extra por número de arquivos
	if [[ "$nr" > "$ns" ]]; then  
		rm -rf $fr/* 2>/dev/null
		cp -r $fs/* $fr/ 2>/dev/null
	fi
	if [[ "$ny" > "$ns" ]]; then  
		rm -rf $fy/* 2>/dev/null
		cp -r $fs/* $fy/ 2>/dev/null
	fi
fi
#
# Sincronizar a partir do Ryujinx se for o mais atual
if [[ "$f" = "r" ]]; then
	if [[ "$dr" > "$dy" ]]; then  
		rm -rf "$fy/"* 2>/dev/null
		rsync -au --delete $fr/ $fy/ 2>/dev/null & 
		wait 
	fi
	if [[ "$dr" > "$ds" ]]; then  
		rm -rf "$fs/"* 2>/dev/null
		rsync -au --delete $fr/ $fs/ 2>/dev/null & 
		wait 
	fi
	# Verificação extra por número de arquivos
	if [[ "$ny" > "$nr" ]]; then  
		rm -rf $fy/* 2>/dev/null
		cp -r $fr/* $fy/ 2>/dev/null
	fi
	if [[ "$ns" > "$nr" ]]; then  
		rm -rf $fs/* 2>/dev/null
		cp -r $fr/* $fs/ 2>/dev/null
	fi
fi
#
# Sincronizar a partir do Yuzu se for o mais atual
if [[ "$f" = "y" ]]; then
	if [[ "$dy" > "$dr" ]]; then  
		rm -rf "$fr/"* 2>/dev/null
		rsync -au --delete $fy/ $fr/ 2>/dev/null & 
		wait 
	fi
	if [[ "$dy" > "$ds" ]]; then  
		rm -rf "$fs/"* 2>/dev/null
		rsync -au --delete $fy/ $fs/ 2>/dev/null & 
		wait 
	fi
	# Verificação extra por número de arquivos
	if [[ "$nr" > "$ny" ]]; then  
		rm -rf $fr/* 2>/dev/null
		cp -r $fy/* $fr/ 2>/dev/null
	fi 
	if [[ "$ns" > "$ny" ]]; then  
		rm -rf $fs/* 2>/dev/null
		cp -r $fy/* $fs/ 2>/dev/null
	fi
fi
#
# ---
# Fim da sincronização
#############################
if [[ "$diag" != "0" ]]; then 
    echo "Arquivo mais recente Ryujinx: $rf"
    echo "Arquivo mais recente Yuzu: $yf"
    echo "Arquivo mais recente BIOS: $sf"
    echo "Data Ryujinx: $dr"
    echo "Data Yuzu: $dy"
    echo "Data BIOS: $ds"
    echo "Tamanho Ryujinx: $sr"
    echo "Tamanho Yuzu: $sy"
    echo "Tamanho BIOS: $ss"
    echo "Nº arquivos Ryujinx: $nr"
    echo "Nº arquivos Yuzu: $ny"
    echo "Nº arquivos BIOS: $ns"
    echo "Fonte escolhida: $f (r=Ryujinx, y=Yuzu, s=BIOS)"
fi
exit 0