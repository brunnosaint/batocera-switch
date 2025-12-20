#!/bin/bash
#
# batocera-switch-patcher.sh
# Script para aplicar patch nos arquivos do emulador Dolphin (GameCube/Wii)
# Corrige o caminho dos plugins Qt para garantir que a configuração gráfica funcione corretamente no Batocera
#
# Aplica duas correções:
# 1. Adiciona QT_PLUGIN_PATH no dolphinGenerator.py
# 2. Atualiza o batocera-config-dolphin para usar QT_PLUGIN_PATH corretamente

# Mudar para o diretório do generator do Dolphin
cd /usr/lib/python*/site-packages/configgen/generators/dolphin
path=$(echo ${PWD})
cd ~/

# Arquivo que será corrigido
file="$path/dolphinGenerator.py"

# Verificar se o patch já foi aplicado (busca por QT_PLUGIN_PATH no arquivo)
ispatched=$(cat "$file" | grep "QT_PLUGIN_PATH")

if [[ "$ispatched" != "" ]]; then 
    # Já está corrigido — não faz nada
    : 
else 
    # Arquivo temporário para construir a versão corrigida
    pfile=/tmp/dolphinGenerator.py
    rm "$pfile" 2>/dev/null

    # Contar total de linhas do arquivo original
    nrlines=$(cat "$file" | wc -l)

    # Percorrer linha por linha
    L=1
    while [[ "$L" -le "$nrlines" ]]; do 
        thisline=$(cat "$file" | sed ''$L'q;d')
        
        # Quando encontrar a linha que define QT_QPA_PLATFORM, inserir a linha com QT_PLUGIN_PATH antes dela
        if [[ "$(echo "$thisline" | grep "QT_QPA_PLATFORM")" != "" ]]; then 
            echo '            "QT_PLUGIN_PATH":"/usr/lib/qt/plugins", \' >> "$pfile"
            echo "$thisline" >> "$pfile"
        else
            echo "$thisline" >> "$pfile"
        fi
        L=$(($L+1))
    done 

    # Substituir o arquivo original pela versão corrigida
    cp "$pfile" "$file"

    # Corrigir o script de configuração do Dolphin para incluir o caminho dos plugins Qt
    sed -i 's,QT_QPA_PLATFORM=xcb,QT_PLUGIN_PATH=/usr/lib/qt/plugins QT_QPA_PLATFORM=xcb,g' /usr/bin/batocera-config-dolphin
fi

# Fim do patch — agora o Dolphin consegue carregar os plugins Qt corretamente