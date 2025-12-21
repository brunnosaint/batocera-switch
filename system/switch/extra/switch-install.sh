#!/bin/bash

# =============================================
# INSTALADOR BRUNNOSAINT SWITCH PARA BATOCERA
# =============================================

# Configurações
INSTALLER_NAME="BrunnoSaint Switch Installer"
DIALOG_TITLE="Instalador Switch"
REPO_BASE="https://raw.githubusercontent.com/brunnosaint/batocera-switch"
LOG_FILE="/userdata/system/switch_installer.log"

# Função para log
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $INSTALLER_NAME: $1" | tee -a "$LOG_FILE"
}

# Função para exibir mensagem de erro
show_error() {
    log_message "ERRO: $1"
    dialog --title "$DIALOG_TITLE" --msgbox "$1" 8 60
    clear
    exit 1
}

# Função para exibir mensagem informativa
show_info() {
    dialog --title "$DIALOG_TITLE" --msgbox "$1" 8 60
}

# Início da instalação
clear
log_message "=== Iniciando instalação ==="

# Verificar se é executado como root
if [[ $EUID -eq 0 ]]; then
    log_message "Aviso: Executando como root"
fi

# 1. Detecção da versão do Batocera
log_message "Detectando versão do Batocera..."

# Tentar obter versão de múltiplas formas
if command -v batocera-es-swissknife &> /dev/null; then
    version_output=$(batocera-es-swissknife --version 2>/dev/null | grep -oE '^[0-9]+')
elif command -v batocera-version &> /dev/null; then
    version_output=$(batocera-version 2>/dev/null | grep -oE '^[0-9]+')
else
    show_error "Não foi possível detectar o Batocera. Verifique se está instalado."
fi

# Verificar se a versão foi detectada
if [[ -z "$version_output" ]] || ! [[ "$version_output" =~ ^[0-9]+$ ]]; then
    show_error "Versão do Batocera não detectada ou inválida."
fi

version=$version_output
log_message "Versão do Batocera detectada: $version"

# 2. Confirmar instalação com o usuário
dialog --title "$DIALOG_TITLE" \
       --yesno "Detectada versão do Batocera: $version\n\nDeseja prosseguir com a instalação do suporte Nintendo Switch?" \
       10 60

if [[ $? -ne 0 ]]; then
    log_message "Instalação cancelada pelo usuário."
    clear
    exit 0
fi

# 3. Executar script apropriado baseado na versão
log_message "Preparando instalação para versão $version..."

case $version in
    39|40)
        log_message "Executando script para Batocera 39/40..."
        show_info "Iniciando instalação para Batocera $version..."
        curl -fsSL "${REPO_BASE}/refs/heads/main/system/switch/extra/batocera-switch-installer-v40.sh" | bash
        ;;
    41)
        log_message "Executando script para Batocera 41..."
        show_info "Iniciando instalação para Batocera $version..."
        curl -fsSL "${REPO_BASE}/refs/heads/main/system/switch/extra/batocera-switch-installer.sh" | bash
        ;;
    42|43|44|45)
        log_message "Executando script para Batocera 42+..."
        show_info "Iniciando instalação para Batocera $version..."
        curl -fsSL "${REPO_BASE}/refs/heads/42/system/switch/extra/batocera-switch-installer.sh" | bash
        ;;
    *)
        show_error "Versão do Batocera não suportada: $version\n\nVersões suportadas: 39 a 45."
        ;;
esac

# 4. Verificar resultado da instalação
install_status=$?
if [[ $install_status -eq 0 ]]; then
    log_message "Instalação concluída com sucesso."
    show_info "Instalação concluída com sucesso!\n\nReinicie o Batocera para aplicar as alterações."
else
    log_message "Instalação falhou com código de erro: $install_status"
    show_error "A instalação falhou. Verifique o log em:\n$LOG_FILE"
fi

clear
log_message "=== Instalação finalizada ==="
exit $install_status