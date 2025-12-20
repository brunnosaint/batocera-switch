#!/bin/bash

################################################################################
# batocera-switch-translator.sh
# Script para aplicar traduções personalizadas do menu Switch no EmulationStation
#
# Funcionamento:
# - Verifica o idioma configurado no Batocera (system.language)
# - Se existir uma tradução para esse idioma em /userdata/system/switch/extra/translations/<idioma>/es_features_switch.cfg,
#   copia ela para o EmulationStation
# - Caso não exista, usa a tradução em inglês (en_US) como padrão
# - Se o arquivo foi alterado, recarrega a lista de jogos para aplicar a tradução imediatamente
#
# IMPORTANTE: O script só faz algo se as pastas de tradução existirem.
# Por padrão, sai imediatamente (exit 0 no início) até que você adicione suas traduções.
################################################################################

# Não executar o script a menos que existam traduções fornecidas
# (Descomente a linha abaixo apenas quando colocar suas traduções na pasta correta)
# exit 0
################################################################################

#-------------------------------------------------------------------------------
# Caminhos importantes
t=/userdata/system/switch/extra/translations                  # Pasta com as traduções
e=/userdata/system/configs/emulationstation                    # Pasta de configuração do EmulationStation
f=es_features_switch.cfg                                       # Arquivo que contém os nomes dos emuladores/menus
reload=maybe                                                   # Flag para decidir se precisa recarregar jogos

# Verificar se o comando batocera-settings-get existe (garante compatibilidade)
if [[ -s /usr/bin/batocera-settings-get ]]; then
    # Obter o idioma configurado no sistema
    lang=$(/usr/bin/batocera-settings-get system.language)
    
    # Se o idioma foi encontrado e não está vazio
    if [[ "$lang" != "not found" ]] && [[ "$lang" != "" ]]; then
        # Se existir tradução específica para o idioma atual
        if [[ -s $t/$lang/$f ]]; then
            # Se o arquivo for diferente do atual no EmulationStation → precisa recarregar
            if [[ "$(diff $t/$lang/$f $e/$f 2>/dev/null)" != "" ]]; then reload=yes; fi
            cp $t/$lang/$f $e/$f
        else
            # Caso não tenha tradução para o idioma → usa inglês como fallback
            if [[ "$(diff $t/en_US/$f $e/$f 2>/dev/null)" != "" ]]; then reload=yes; fi
            cp $t/en_US/$f $e/$f
        fi
    else
        # Idioma não configurado ou inválido → usa inglês
        if [[ "$(diff $t/en_US/$f $e/$f 2>/dev/null)" != "" ]]; then reload=yes; fi
        cp $t/en_US/$f $e/$f
    fi
else
    # Se não conseguir ler a configuração → usa inglês como padrão seguro
    if [[ -s $t/en_US/$f ]]; then
        if [[ "$(diff $t/en_US/$f $e/$f 2>/dev/null)" != "" ]]; then reload=yes; fi
        cp $t/en_US/$f $e/$f
    fi
fi

# Se alguma tradução foi aplicada/alterada → recarrega a lista de jogos para atualizar o menu
if [[ "$reload" = "yes" ]]; then 
    curl http://127.0.0.1:1234/reloadgames
fi

exit 0
#-------------------------------------------------------------------------------