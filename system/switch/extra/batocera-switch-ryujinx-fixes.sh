#!/bin/bash

# batocera-switch-ryujinx-fixes.sh
# Script para corrigir e otimizar automaticamente as configurações do Ryujinx no Batocera
# Aplica ajustes importantes no Config.json e LDNConfig.json:
# - Define fuso horário correto
# - Corrige offset de horário (desativado por inconsistência no Ryujinx)
# - Inicia sempre em tela cheia
# - Desativa verificação de atualizações ao iniciar
# - Adiciona automaticamente a pasta /userdata/roms/switch como diretório de jogos

# Obter fuso horário do sistema
[ -e /etc/timezone ] && TZ=$(cat /etc/timezone)
[ -z $TZ ] && TZ="UTC"

# Calcular offset de horário (em relação ao UTC)
# Nota: O Ryujinx tem inconsistências ao interpretar offsets negativos/positivos,
# por isso deixamos fixo em 0 para evitar problemas de data/hora nos jogos
utc="$(TZ="UTC" date +%z | cut -c2- | sed 's/^0*//')" && [ -z "$utc" ] && utc=0
tim="$(TZ="$TZ" date +%z | cut -c2- | sed 's/^0*//')" && [ -z "$tim" ] && tim=0
    # Cálculo original (comentado por causa da inconsistência no Ryujinx)
    # offset=$(( ( $(echo "$(TZ="$TZ" date +%z | cut -c1-1)$tim") - $(echo "$(TZ="Europe/London" date +%z | cut -c1-1)$utc") ) / 100 * 3600 ))
    offset="0"  # Valor fixo para maior compatibilidade

# Função para aplicar as correções em um arquivo JSON específico
function update() {
    file="${1}"
    
    # Definir fuso horário do sistema
    sed -i 's|"system_time_zone".*:.*|"system_time_zone": "'$TZ'",|' "$file" 2>/dev/null
    
    # Definir offset de horário (fixo em 0)
    sed -i 's|"system_time_offset".*:.*|"system_time_offset": '$offset',|' "$file" 2>/dev/null
    
    # Iniciar sempre em tela cheia
    sed -i 's|"start_fullscreen".*:.*|"start_fullscreen": true,|' "$file" 2>/dev/null
    
    # Desativar verificação de atualizações ao iniciar (economiza tempo e evita travas)
    sed -i 's|"check_updates_on_start".*:.*|"check_updates_on_start": false,|' "$file" 2>/dev/null
    
    # Adicionar pasta de ROMs do Switch como diretório de jogos (se ainda não existir)
    sed -i 's;  "game_dirs"\: \[]\,;  "game_dirs"\: \["/userdata/roms/switch"]\,;g' "$file" 2>/dev/null
}

# Aplicar correções nos dois arquivos de configuração principais do Ryujinx
update /userdata/system/configs/Ryujinx/Config.json
update /userdata/system/configs/Ryujinx/LDNConfig.json

exit 0