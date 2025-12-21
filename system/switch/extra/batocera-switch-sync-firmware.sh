#!/bin/bash
#   //====================================//
#  //  Sincronizador de Firmware Switch  //
# //====================================//
#
# Definir caminhos dos diretórios de firmware
fr=/userdata/system/configs/Ryujinx/bis/system/Contents/registered  # Firmware Ryujinx
fy=/userdata/system/configs/yuzu/nand/system/Contents/registered    # Firmware Yuzu
fs=/userdata/bios/switch/firmware                                   # Diretório firmware principal

# Criar diretórios se não existirem
mkdir -p $fr 2>/dev/null
mkdir -p $fy 2>/dev/null
mkdir -p $fs 2>/dev/null

# Variável de diagnóstico (0=desativado, 1=ativado)
diag=0

# Preparar flags de verificação para cada diretório
cr=1  # Ryujinx
cy=1  # Yuzu
cs=1  # Diretório principal

# Preparar ferramenta 'stat' personalizada
if [[ ! -e /userdata/system/switch/extra/batocera-switch-stat ]]; then 
    # Baixar se não existir
    url_stat=https://github.com/brunnosaint/batocera-switch/raw/main/system/switch/extra/batocera-switch-stat
    wget -q --no-check-certificate --no-cache --no-cookies -O /userdata/system/switch/extra/batocera-switch-stat $url_stat
elif [[ "$(wc -c /userdata/system/switch/extra/batocera-switch-stat | awk '{print $1}')" < "90000" ]]; then 
    # Baixar novamente se o arquivo estiver corrompido (muito pequeno)
    url_stat=https://github.com/brunnosaint/batocera-switch/raw/main/system/switch/extra/batocera-switch-stat
    wget -q --no-check-certificate --no-cache --no-cookies -O /userdata/system/switch/extra/batocera-switch-stat $url_stat
fi 
chmod a+x /userdata/system/switch/extra/batocera-switch-stat 2>/dev/null

# Verificar arquivos mais recentemente modificados em cada diretório
rf=$(ls $fr -Art | grep ".nca" | tail -n 1)  # Último arquivo .nca no Ryujinx
yf=$(ls $fy -Art | grep ".nca" | tail -n 1)  # Último arquivo .nca no Yuzu
sf=$(ls $fs -Art | grep ".nca" | tail -n 1)  # Último arquivo .nca no diretório principal

# Obter timestamp do último arquivo modificado
if [[ "$rf" = "" ]]; then cr=0; else dr=$(/userdata/system/switch/extra/batocera-switch-stat -c "%Y" $fr/$rf 2>/dev/null); fi
if [[ "$yf" = "" ]]; then cy=0; else dy=$(/userdata/system/switch/extra/batocera-switch-stat -c "%Y" $fy/$yf 2>/dev/null); fi
if [[ "$sf" = "" ]]; then cs=0; else ds=$(/userdata/system/switch/extra/batocera-switch-stat -c "%Y" $fs/$sf 2>/dev/null); fi

# Verificar tamanho dos diretórios (se muito pequeno, considerar vazio)
sr=$(du -Hs $fr | awk '{print $1}')
sy=$(du -Hs $fy | awk '{print $1}')
ss=$(du -Hs $fs | awk '{print $1}')

if [[ "$sr" -le "200000" ]]; then cr=0; fi  # Menor que 200MB
if [[ "$sy" -le "200000" ]]; then cy=0; fi  # Menor que 200MB
if [[ "$ss" -le "200000" ]]; then cs=0; fi  # Menor que 200MB

# Verificar número de arquivos em cada diretório (se muito poucos, considerar vazio)
nr=$(find $fr -type f | wc -l)  # Contar arquivos no Ryujinx
ny=$(find $fy -type f | wc -l)  # Contar arquivos no Yuzu
ns=$(find $fs -type f | wc -l)  # Contar arquivos no diretório principal

if [[ "$nr" -le "200" ]]; then cr=0; fi  # Menos de 200 arquivos
if [[ "$ny" -le "200" ]]; then cy=0; fi  # Menos de 200 arquivos
if [[ "$ns" -le "200" ]]; then cs=0; fi  # Menos de 200 arquivos

# =============================================================================
# ENCONTRAR FIRMWARE MAIS RECENTE
# =============================================================================
# Determinar qual diretório tem o firmware mais recente baseado no timestamp
if [[ "$dr" != "" ]] && [[ "$dr" -ge "$dy" ]] && [[ "$dr" -ge "$ds" ]]; then f=r; fi  # Ryujinx mais recente
if [[ "$dy" != "" ]] && [[ "$dy" -ge "$dr" ]] && [[ "$dy" -ge "$ds" ]]; then f=y; fi  # Yuzu mais recente
if [[ "$ds" != "" ]] && [[ "$ds" -ge "$dr" ]] && [[ "$ds" -ge "$dy" ]]; then f=s; fi  # Diretório principal mais recente

# =============================================================================
# CASO 1: Diretório principal tem o firmware mais recente (fs)
# =============================================================================
if [[ "$f" = "s" ]]; then
    # Sincronizar do diretório principal para Ryujinx se necessário
    if [[ "$ds" > "$dr" ]]; then  
        rm -rf "$fr/"* 2>/dev/null  # Limpar diretório Ryujinx
        rsync -au --delete $fs/ $fr/ 2>/dev/null &  # Sincronizar
        wait 
    fi
    
    # Sincronizar do diretório principal para Yuzu se necessário
    if [[ "$ds" > "$dy" ]]; then  
        rm -rf "$fy/"* 2>/dev/null  # Limpar diretório Yuzu
        rsync -au --delete $fs/ $fy/ 2>/dev/null &  # Sincronizar
        wait 
    fi
    
    # Verificação adicional baseada no número de arquivos
    if [[ "$nr" > "$ns" ]]; then  
        rm -rf $fr/* 2>/dev/null
        cp -r $fs/* $fr/ 2>/dev/null  # Copiar se Ryujinx tiver mais arquivos (possivelmente corrompido)
    fi
    
    if [[ "$ny" > "$ns" ]]; then  
        rm -rf $fy/* 2>/dev/null
        cp -r $fs/* $fy/ 2>/dev/null  # Copiar se Yuzu tiver mais arquivos (possivelmente corrompido)
    fi
fi

# =============================================================================
# CASO 2: Ryujinx tem o firmware mais recente (fr)
# =============================================================================
if [[ "$f" = "r" ]]; then
    # Sincronizar do Ryujinx para Yuzu se necessário
    if [[ "$dr" > "$dy" ]]; then  
        rm -rf "$fy/"* 2>/dev/null  # Limpar diretório Yuzu
        rsync -au --delete $fr/ $fy/ 2>/dev/null &  # Sincronizar
        wait 
    fi
    
    # Sincronizar do Ryujinx para diretório principal se necessário
    if [[ "$dr" > "$ds" ]]; then  
        rm -rf "$fs/"* 2>/dev/null  # Limpar diretório principal
        rsync -au --delete $fr/ $fs/ 2>/dev/null &  # Sincronizar
        wait 
    fi
    
    # Verificação adicional baseada no número de arquivos
    if [[ "$ny" > "$nr" ]]; then  
        rm -rf $fy/* 2>/dev/null
        cp -r $fr/* $fy/ 2>/dev/null  # Copiar se Yuzu tiver mais arquivos (possivelmente corrompido)
    fi
    
    if [[ "$ns" > "$nr" ]]; then  
        rm -rf $fs/* 2>/dev/null
        cp -r $fr/* $fs/ 2>/dev/null  # Copiar se diretório principal tiver mais arquivos (possivelmente corrompido)
    fi
fi

# =============================================================================
# CASO 3: Yuzu tem o firmware mais recente (fy)
# =============================================================================
if [[ "$f" = "y" ]]; then
    # Sincronizar do Yuzu para Ryujinx se necessário
    if [[ "$dy" > "$dr" ]]; then  
        rm -rf "$fr/"* 2>/dev/null  # Limpar diretório Ryujinx
        rsync -au --delete $fy/ $fr/ 2>/dev/null &  # Sincronizar
        wait 
    fi
    
    # Sincronizar do Yuzu para diretório principal se necessário
    if [[ "$dy" > "$ds" ]]; then  
        rm -rf "$fs/"* 2>/dev/null  # Limpar diretório principal
        rsync -au --delete $fy/ $fs/ 2>/dev/null &  # Sincronizar
        wait 
    fi
    
    # Verificação adicional baseada no número de arquivos
    if [[ "$nr" > "$ny" ]]; then  
        rm -rf $fr/* 2>/dev/null
        cp -r $fy/* $fr/ 2>/dev/null  # Copiar se Ryujinx tiver mais arquivos (possivelmente corrompido)
    fi 
    
    if [[ "$ns" > "$ny" ]]; then  
        rm -rf $fs/* 2>/dev/null
        cp -r $fy/* $fs/ 2>/dev/null  # Copiar se diretório principal tiver mais arquivos (possivelmente corrompido)
    fi
fi

# =============================================================================
# SAÍDA DE DIAGNÓSTICO (se ativada)
# =============================================================================
if [[ "$diag" != "0" ]]; then 
    echo "Arquivo mais recente Ryujinx: rf=$rf"
    echo "Arquivo mais recente Yuzu: yf=$yf"
    echo "Arquivo mais recente diretório principal: sf=$sf"
    echo "Timestamp Ryujinx: dr=$dr"
    echo "Timestamp Yuzu: dy=$dy"
    echo "Timestamp diretório principal: ds=$ds"
    echo "Tamanho diretório Ryujinx: sr=$sr"
    echo "Tamanho diretório Yuzu: sy=$sy"
    echo "Tamanho diretório principal: ss=$ss"
    echo "Número arquivos Ryujinx: nr=$nr"
    echo "Número arquivos Yuzu: ny=$ny"
    echo "Número arquivos diretório principal: ns=$ns"
    echo "Firmware mais recente encontrado: fw=$f"
fi

exit 0