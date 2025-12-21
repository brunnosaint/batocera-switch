#!/bin/bash

################################################################################
# Não executar a menos que as traduções estejam disponíveis
# (Script desativado - configurar traduções primeiro)
  exit 0
################################################################################

#-------------------------------------------------------------------------------
# Configurar caminhos para arquivos de tradução
t=/userdata/system/switch/extra/translations  # Diretório de traduções
e=/userdata/system/configs/emulationstation   # Diretório do EmulationStation
f=es_features_switch.cfg                      # Arquivo de features do Switch
reload=maybe                                  # Flag para recarregar jogos

# Verificar se o comando de configurações do Batocera está disponível
if [[ -s /usr/bin/batocera-settings-get ]]; then
    # Obter idioma configurado no sistema
    lang=$(/usr/bin/batocera-settings-get system.language)
    
    # Se idioma for encontrado e não estiver vazio
    if [[ "$lang" != "not found" ]] && [[ "$lang" != "" ]]; then
        # Verificar se existe tradução para o idioma configurado
        if [[ -s $t/$lang/$f ]]; then
            # Se arquivo de tradução for diferente do atual, marcar para recarregar
            if [[ "$(diff $t/$lang/$f $e/$f)" != "" ]]; then reload=yes; fi
            # Copiar tradução específica do idioma
            cp $t/$lang/$f $e/$f
        else
            # Se não houver tradução específica, usar inglês (en_US)
            if [[ "$(diff $t/en_US/$f $e/$f)" != "" ]]; then reload=yes; fi
            cp $t/en_US/$f $e/$f
        fi
    else
        # Se idioma não estiver configurado, usar inglês (en_US)
        if [[ "$(diff $t/en_US/$f $e/$f)" != "" ]]; then reload=yes; fi
        cp $t/en_US/$f $e/$f
    fi
fi

# Recarregar lista de jogos se necessário
if [[ "$reload" = "yes" ]]; then 
    curl http://127.0.0.1:1234/reloadgames
fi

exit 0
#-------------------------------------------------------------------------------