#!/bin/bash

# Detecção da versão principal do Batocera
version=$(batocera-es-swissknife --version | grep -oE '^[0-9]+')

# Verifica se a versão foi detectada corretamente
if [[ -z "$version" ]]; then
    dialog --msgbox "Não foi possível detectar uma versão válida do Batocera. Instalação cancelada." 8 60
    clear
    exit 1
fi

echo "[Foclabroc Switch Installer] Versão detectada do Batocera: $version"
sleep 2

# Escolhe o script correto conforme a versão
case $version in
    39|40)
        echo "[Foclabroc Switch Installer] Iniciando script para Batocera 39/40..."
        sleep 3
        curl -fsSL https://raw.githubusercontent.com/brunnosaint/batocera-switch/refs/heads/main/system/switch/extra/batocera-switch-installer-v40.sh | bash
        ;;
    41)
        echo "[Foclabroc Switch Installer] Iniciando script para Batocera 41..."
        sleep 3
        curl -fsSL https://raw.githubusercontent.com/brunnosaint/batocera-switch/refs/heads/main/system/switch/extra/batocera-switch-installer.sh | bash
        ;;
    42|43|44)
        echo "[Foclabroc Switch Installer] Iniciando script para Batocera 42/43/44..."
        sleep 3
        curl -fsSL https://raw.githubusercontent.com/brunnosaint/batocera-switch/refs/heads/42/system/switch/extra/batocera-switch-installer.sh | bash
        ;;
    *)
        echo "[Foclabroc Switch Installer] Versão não suportada: $version"
        dialog --msgbox "Versão do Batocera não suportada: $version. Instalação cancelada." 8 60
        clear
        ;;
esac