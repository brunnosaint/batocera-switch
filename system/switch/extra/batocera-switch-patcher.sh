#!/bin/bash
#
# Corrigir dolphinGenerator.py e batocera-config-dolphin para usar QT_PLUGIN_PATH=/usr/lib/qt/plugins 

# Navegar para o diretório do gerador Dolphin
cd /usr/lib/python*/site-packages/configgen/generators/dolphin
path=$(echo ${PWD})
cd ~/

# Verificar se o arquivo dolphinGenerator.py já foi corrigido
file="$path/dolphinGenerator.py"
ispatched=$(cat "$file" | grep "QT_PLUGIN_PATH")

if [[ "$ispatched" != "" ]]; then 
    # Arquivo já corrigido, não fazer nada
    : 
else 
    # Criar arquivo temporário para aplicar a correção
    pfile=/tmp/dolphinGenerator.py
    rm "$pfile" 2>/dev/null
    
    # Obter número total de linhas no arquivo
    nrlines=$(cat "$file" | wc -l)
    
    # Processar cada linha do arquivo original
    L=1
    while [[ "$L" -le "$nrlines" ]]; do 
        thisline=$(cat $file | sed ''$L'q;d')
        
        # Se encontrar a linha com QT_QPA_PLATFORM, adicionar QT_PLUGIN_PATH antes dela
        if [[ "$(echo "$thisline" | grep "QT_QPA_PLATFORM")" != "" ]]; then 
            echo '            "QT_PLUGIN_PATH":"/usr/lib/qt/plugins", \' >> "$pfile"
            echo "$thisline" >> "$pfile"
        else
            echo "$thisline" >> "$pfile"
        fi
        
        L=$(($L+1))
    done 
    
    # Substituir o arquivo original pelo corrigido
    cp "$pfile" "$file"
    
    # Também corrigir o script batocera-config-dolphin
    sed -i 's,QT_QPA_PLATFORM=xcb,QT_PLUGIN_PATH=/usr/lib/qt/plugins QT_QPA_PLATFORM=xcb,g' /usr/bin/batocera-config-dolphin
fi

# Fim da correção de dolphinGenerator.py e batocera-config-dolphin para usar QT_PLUGIN_PATH=/usr/lib/qt/plugins