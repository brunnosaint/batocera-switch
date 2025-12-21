#!/bin/bash

# Obter fuso horário do sistema
[ -e /etc/timezone ] && TZ=$(cat /etc/timezone)
[ -z $TZ ] && TZ="UTC"

# Calcular offset de tempo (desativado por inconsistência do Ryujinx)
utc="$(TZ="UTC" date +%z | cut -c2- | sed 's/^0*//')" && [ -z "$utc" ] && utc=0
tim="$(TZ="$TZ" date +%z | cut -c2- | sed 's/^0*//')" && [ -z "$tim" ] && tim=0
# Cálculo de offset comentado devido a inconsistências no Ryujinx
# offset=$(( ( $(echo "$(TZ="$TZ" date +%z | cut -c1-1)$tim") - $(echo "$(TZ="Europe/London" date +%z | cut -c1-1)$utc") ) / 100 * 3600))
offset="0"

# Função para atualizar arquivos de configuração do Ryujinx
function update() {
    file="${1}"  # Recebe o caminho do arquivo como parâmetro
    
    # Aplicar substituições no arquivo de configuração
    sed -i 's|"system_time_zone".*:.*|"system_time_zone": "'$TZ'",|' "$file" 2>/dev/null
    sed -i 's|"system_time_offset".*:.*|"system_time_offset": '$offset',|' "$file" 2>/dev/null
    sed -i 's|"start_fullscreen".*:.*|"start_fullscreen": true,|' "$file" 2>/dev/null
    sed -i 's|"check_updates_on_start".*:.*|"check_updates_on_start": false,|' "$file" 2>/dev/null
    sed -i 's;  "game_dirs"\: \[]\,;  "game_dirs"\: \["/userdata/roms/switch"]\,;g' "$file" 2>/dev/null
}

# Atualizar ambos os arquivos de configuração do Ryujinx
update /userdata/system/configs/Ryujinx/Config.json
update /userdata/system/configs/Ryujinx/LDNConfig.json

exit 0