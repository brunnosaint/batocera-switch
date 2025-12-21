#!/usr/bin/env bash
# ==============================================================================
# BATOCERA.PRO SWITCH EMULATION INSTALLER
# Script de instalação do pacote Nintendo Switch para Batocera 42+
# ==============================================================================

set -e  # Saída em caso de erro crítico
set -u  # Trata variáveis não definidas como erro

# ------------------------------------------------------------------------------
# CONFIGURAÇÕES GLOBAIS
# ------------------------------------------------------------------------------
readonly APPNAME="SWITCH EMULATION FOR 42+"
readonly ORIGIN="github.com/brunnosaint/batocera-switch"
readonly BASE_URL="https://raw.githubusercontent.com/brunnosaint/batocera-switch/refs/heads/42"
readonly EXTRA_DIR="/userdata/system/switch/extra"
readonly LOG_FILE="/userdata/system/switch_install.log"
readonly CONFIG_FILE="/userdata/system/switch/CONFIG.txt"
readonly BACKUP_CONFIG="/tmp/.userconfigfile"

# Cores para output
readonly X='\033[0m'       # Reset
readonly R='\033[1;31m'    # Vermelho
readonly G='\033[1;32m'    # Verde
readonly B='\033[1;34m'    # Azul
readonly P='\033[1;35m'    # Roxo
readonly Y='\033[1;33m'    # Amarelo
readonly W='\033[1;37m'    # Branco

# ------------------------------------------------------------------------------
# FUNÇÕES DE LOG E UTILITÁRIAS
# ------------------------------------------------------------------------------

log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

log_success() {
    log_message "✅ $1"
    echo -e "${G}✓${X} $1"
}

log_warning() {
    log_message "⚠️  $1"
    echo -e "${Y}⚠${X} $1"
}

log_error() {
    log_message "❌ $1"
    echo -e "${R}✗${X} $1"
}

log_info() {
    log_message "ℹ️  $1"
    echo -e "${B}→${X} $1"
}

# Função para download com retry
download_file() {
    local url="$1"
    local output="$2"
    local max_retries=3
    local retry_delay=2
    
    for ((i=1; i<=max_retries; i++)); do
        if wget -q --no-check-certificate --no-cache --no-cookies -O "$output" "$url"; then
            return 0
        fi
        
        log_warning "Tentativa $i falhou: $url"
        if [[ $i -lt $max_retries ]]; then
            sleep $retry_delay
        fi
    done
    
    log_error "Falha ao baixar: $url"
    return 1
}

# Função para criar diretórios
create_directories() {
    log_info "Criando estrutura de diretórios..."
    
    # Diretórios principais
    local dirs=(
        "/userdata/system/switch"
        "/userdata/system/switch/extra"
        "/userdata/system/switch/configgen"
        "/userdata/system/switch/configgen/generators"
        "/userdata/system/switch/configgen/generators/citron"
        "/userdata/system/switch/configgen/generators/yuzu"
        "/userdata/system/switch/configgen/generators/ryujinx"
        "/userdata/system/switch/configgen/generators/sudachi"
        "/userdata/system/switch/configgen/generators/eden"
        
        "/userdata/system/configs/evmapy"
        "/userdata/system/configs/emulationstation"
        
        "/userdata/roms/switch"
        "/userdata/roms/ports"
        "/userdata/roms/ports/images"
        
        "/userdata/bios/switch"
        "/userdata/bios/switch/firmware"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir" 2>/dev/null && \
            log_success "Criado: $dir" || \
            log_warning "Falha ao criar: $dir"
        fi
    done
}

# Função para limpar instalações antigas
cleanup_old_installation() {
    log_info "Limpando instalações antigas..."
    
    # Arquivos para remover
    local files_to_remove=(
        "/userdata/system/switch/*.AppImage"
        "/userdata/system/switch/CONFIG.txt"
        "/userdata/system/configs/emulationstation/add_feat_switch.cfg"
        "/userdata/system/configs/emulationstation/es_systems_switch.cfg"
        "/userdata/system/configs/emulationstation/es_features_switch.cfg"
        "/userdata/system/configs/emulationstation/es_features.cfg"
        "/userdata/roms/ports/Sudachi Qlauncher.sh"
        "/userdata/roms/ports/Sudachi Qlauncher.sh.keys"
        "/userdata/roms/ports/Switch Updater40.sh.keys"
        "/userdata/roms/ports/Switch Updater40.sh"
        "/userdata/system/switch/extra/suyu.png"
        "/userdata/system/switch/extra/suyu-config.desktop"
        "/userdata/system/switch/extra/batocera-config-suyu"
        "/userdata/system/switch/extra/batocera-config-suyuQL"
        "/userdata/system/.local/share/applications/suyu-config.desktop"
        "/userdata/roms/ports/Suyu Qlauncher.sh.keys"
        "/userdata/roms/ports/Suyu Qlauncher.sh"
        "/userdata/system/configs/evmapy/switch.keys"
        
        # Updaters antigos
        "/userdata/roms/ports/updateyuzu.sh"
        "/userdata/roms/ports/updateyuzuea.sh"
        "/userdata/roms/ports/updateyuzuEA.sh"
        "/userdata/roms/ports/updateryujinx.sh"
        "/userdata/roms/ports/updateryujinxavalonia.sh"
        
        # Imagens antigas do Switch Updater
        "/userdata/roms/ports/images/Switch Updater-boxart.png"
        "/userdata/roms/ports/images/Switch Updater-cartridge.png"
        "/userdata/roms/ports/images/Switch Updater-mix.png"
        "/userdata/roms/ports/images/Switch Updater-screenshot.png"
        "/userdata/roms/ports/images/Switch Updater-wheel.png"
    )
    
    for file in "${files_to_remove[@]}"; do
        if [[ -e "$file" ]]; then
            rm -f "$file" 2>/dev/null && \
            log_success "Removido: $file" || \
            log_warning "Falha ao remover: $file"
        fi
    done
    
    # Diretórios para limpar (não remover completamente)
    local dirs_to_clean=(
        "/userdata/system/switch/configgen"
        "/userdata/system/switch/extra"
        "/userdata/system/switch/logs"
        "/userdata/system/switch/sudachi"
    )
    
    for dir in "${dirs_to_clean[@]}"; do
        if [[ -d "$dir" ]]; then
            rm -rf "$dir"/* 2>/dev/null || true
        fi
    done
}

# Função para verificar sistema
check_system() {
    log_info "Verificando sistema..."
    
    # Verificar arquitetura
    if ! uname -a | grep -q "x86_64"; then
        log_error "SISTEMA NÃO SUPORTADO"
        log_error "Você precisa do Batocera x86_64"
        return 1
    fi
    
    # Desativar IPv6 temporariamente
    sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1
    sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
    
    log_success "Sistema compatível: Batocera x86_64"
    return 0
}

# Função para preservar/configurar arquivo de configuração
preserve_config_file() {
    log_info "Preservando arquivo de configuração..."
    
    if [[ -f "$CONFIG_FILE" ]]; then
        # Fazer backup da configuração do usuário
        cp "$CONFIG_FILE" "$BACKUP_CONFIG" 2>/dev/null || \
        log_warning "Não foi possível fazer backup do arquivo de configuração"
        
        # Verificar e atualizar versão do arquivo de configuração
        local default_config_url="${BASE_URL}/system/switch/extra/batocera-switch-config.txt"
        local temp_config="/tmp/.CONFIG.txt"
        
        if download_file "$default_config_url" "$temp_config"; then
            local current_ver=$(grep "(ver " "$CONFIG_FILE" 2>/dev/null | head -n1 | sed 's/^.*(ver //g' | cut -d ")" -f1)
            local latest_ver=$(grep "(ver " "$temp_config" 2>/dev/null | head -n1 | sed 's/^.*(ver //g' | cut -d ")" -f1)
            
            current_ver="${current_ver:-1.0.0}"
            latest_ver="${latest_ver:-1.0.0}"
            
            if [[ "$latest_ver" > "$current_ver" ]]; then
                cp "$temp_config" "$CONFIG_FILE" 2>/dev/null && \
                log_success "Arquivo CONFIG.txt atualizado para versão $latest_ver"
            fi
        fi
    else
        # Baixar arquivo de configuração padrão
        local config_url="${BASE_URL}/system/switch/extra/batocera-switch-config.txt"
        download_file "$config_url" "$CONFIG_FILE" && \
        log_success "Arquivo CONFIG.txt baixado"
    fi
}

# Função para baixar arquivos em lote
download_batch_files() {
    local base_path="$1"
    local url_path="$2"
    shift 2
    local files=("$@")
    
    for file in "${files[@]}"; do
        local url="${BASE_URL}/${url_path}/${file}"
        local output="${base_path}/${file}"
        
        if download_file "$url" "$output"; then
            log_success "Baixado: $file"
        else
            log_warning "Falha ao baixar: $file"
        fi
    done
}

# Função para configurar permissões
set_permissions() {
    log_info "Configurando permissões..."
    
    # Converter quebras de linha DOS/Unix
    if command -v dos2unix >/dev/null 2>&1; then
        dos2unix "$EXTRA_DIR"/*.sh 2>/dev/null || true
        dos2unix "$EXTRA_DIR"/batocera-config* 2>/dev/null || true
    else
        # Fallback usando sed
        find "$EXTRA_DIR" -name "*.sh" -exec sed -i 's/\r$//' {} \; 2>/dev/null || true
        find "$EXTRA_DIR" -name "batocera-config*" -exec sed -i 's/\r$//' {} \; 2>/dev/null || true
    fi
    
    # Configurar permissões de execução
    chmod a+x "$EXTRA_DIR"/*.sh 2>/dev/null || true
    chmod a+x "$EXTRA_DIR"/batocera-config* 2>/dev/null || true
    chmod a+x "$EXTRA_DIR"/batocera-switch-lib* 2>/dev/null || true
    chmod a+x "$EXTRA_DIR"/*.desktop 2>/dev/null || true
    chmod a+x /userdata/system/.local/share/applications/*.desktop 2>/dev/null || true
    
    log_success "Permissões configuradas"
}

# Função para executar atualizador
run_updater() {
    log_info "Executando Switch Updater..."
    
    local updater_url="${BASE_URL}/system/switch/extra/batocera-switch-updater.sh"
    local temp_updater="/tmp/batocera-switch-updater.sh"
    
    # Remover instalações anteriores
    rm -rf "$EXTRA_DIR/installation" 2>/dev/null
    
    # Baixar atualizador
    if download_file "$updater_url" "$temp_updater"; then
        # Modificar para modo console
        sed -i 's/MODE=DISPLAY/MODE=CONSOLE/g' "$temp_updater" 2>/dev/null
        
        # Configurar permissões
        if command -v dos2unix >/dev/null 2>&1; then
            dos2unix "$temp_updater" 2>/dev/null
        fi
        chmod a+x "$temp_updater" 2>/dev/null
        
        # Executar atualizador
        if "$temp_updater" CONSOLE; then
            echo "OK" > "$EXTRA_DIR/installation"
            log_success "Updater executado com sucesso"
        else
            log_error "Falha ao executar updater"
            return 1
        fi
    else
        log_error "Falha ao baixar updater"
        return 1
    fi
    
    # Restaurar arquivo de configuração do usuário se existir
    if [[ -e "$BACKUP_CONFIG" ]]; then
        cp "$BACKUP_CONFIG" "$CONFIG_FILE" 2>/dev/null && \
        log_success "Configuração do usuário restaurada"
    fi
    
    return 0
}

# Função para mostrar animação de inicialização
show_boot_animation() {
    clear
    for i in {1..5}; do
        case $i in
            1)
                echo -e "\n\n\n${X}${X}$APPNAME${X} INSTALLER ${X}\n\n\n"
                sleep 0.33
                clear
                ;;
            2)
                echo -e "\n\n\n${X}${X}$APPNAME${X} INSTALLER ${X}\n\n\n"
                sleep 0.33
                clear
                ;;
            3)
                echo -e "\n\n${X}- - - - - - - - -\n${X}${X}$APPNAME${X} INSTALLER ${X}\n- - - - - - - - -\n\n"
                sleep 0.33
                clear
                ;;
            4)
                echo -e "\n${X}- - - - - - - - -\n\n${X}${X}$APPNAME${X} INSTALLER ${X}\n\n- - - - - - - - -\n"
                sleep 0.33
                clear
                ;;
            5)
                echo -e "${X}- - - - - - - - -\n\n\n${X}${X}$APPNAME${X} INSTALLER ${X}\n\n\n- - - - - - - - -"
                sleep 0.33
                clear
                ;;
        esac
    done
    
    clear
    echo -e "\n\n\n${X}${X}$APPNAME${X} INSTALLER ${X}\n\n\n"
    sleep 0.33
    
    echo -e "${X}INSTALANDO $APPNAME PARA BATOCERA"
    echo -e "${X}USANDO ${ORIGIN^^}"
    echo -e "\n\n"
    sleep 2
}

# ------------------------------------------------------------------------------
# FUNÇÃO PRINCIPAL DE INSTALAÇÃO
# ------------------------------------------------------------------------------
main_installation() {
    log_message "=== INICIANDO INSTALAÇÃO DO BATOCERA-SWITCH ==="
    
    # Mostrar animação inicial
    show_boot_animation
    
    # Verificar sistema
    if ! check_system; then
        sleep 5
        exit 1
    fi
    
    # Iniciar processo
    echo -e "${X}AGUARDE${X} . . ."
    echo
    
    # 1. Preservar arquivo de configuração
    preserve_config_file
    
    # 2. Limpar instalações antigas
    cleanup_old_installation
    
    # 3. Criar diretórios necessários
    create_directories
    
    log_info "Baixando arquivos necessários..."
    
    # 4. Baixar arquivos para /userdata/system/switch/extra
    extra_files=(
        "batocera-config-ryujinx"
        "batocera-config-sudachi"
        "batocera-config-sudachiQL"
        "batocera-config-yuzuEA"
        "batocera-switch-libselinux.so.1"
        "batocera-switch-libthai.so.0.3"
        "batocera-switch-libtinfo.so.6"
        "batocera-switch-sshupdater.sh"
        "batocera-switch-tar"
        "batocera-switch-tput"
        "batocera-switch-updater.sh"
        "icon_ryujinx.png"
        "icon_ryujinxg.png"
        "libthai.so.0.3.1"
        "ryujinx-avalonia.png"
        "ryujinx.png"
        "yuzuEA.png"
        "sudachi.png"
        "citron.png"
        "batocera-config-citron"
        "eden.png"
        "batocera-config-eden"
    )
    download_batch_files "$EXTRA_DIR" "system/switch/extra" "${extra_files[@]}"
    
    # 5. Baixar geradores Ryujinx
    ryujinx_files=("__init__.py" "ryujinxMainlineGenerator.py")
    download_batch_files "/userdata/system/switch/configgen/generators/ryujinx" \
                        "system/switch/configgen/generators/ryujinx" \
                        "${ryujinx_files[@]}"
    
    # 6. Baixar geradores Citron
    citron_files=("citronGenerator.py" "citronwrapper.sh")
    download_batch_files "/userdata/system/switch/configgen/generators/citron" \
                        "system/switch/configgen/generators/citron" \
                        "${citron_files[@]}"
    
    # 7. Baixar geradores Eden
    eden_files=("edenGenerator.py")
    download_batch_files "/userdata/system/switch/configgen/generators/eden" \
                        "system/switch/configgen/generators/eden" \
                        "${eden_files[@]}"
    
    # 8. Baixar geradores Sudachi
    sudachi_files=("sudachiGenerator.py")
    download_batch_files "/userdata/system/switch/configgen/generators/sudachi" \
                        "system/switch/configgen/generators/sudachi" \
                        "${sudachi_files[@]}"
    
    # 9. Baixar geradores Yuzu
    yuzu_files=("__init__.py" "yuzuMainlineGenerator.py")
    download_batch_files "/userdata/system/switch/configgen/generators/yuzu" \
                        "system/switch/configgen/generators/yuzu" \
                        "${yuzu_files[@]}"
    
    # 10. Baixar arquivos do configgen
    configgen_files=(
        "__init__.py"
        "Generator.py"
        "GeneratorImporter.py"
        "switchlauncher.py"
        "configgen-defaults.yml"
        "configgen-defaults-arch.yml"
        "Emulator.py"
        "batoceraFiles.py"
        "controllersConfig.py"
        "evmapy.py"
        "unixSettings.py"
    )
    
    # Arquivos em generators/
    download_batch_files "/userdata/system/switch/configgen/generators" \
                        "system/switch/configgen/generators" \
                        "__init__.py" "Generator.py"
    
    # Arquivos em configgen/
    download_batch_files "/userdata/system/switch/configgen" \
                        "system/switch/configgen" \
                        "GeneratorImporter.py" "switchlauncher.py" \
                        "configgen-defaults.yml" "configgen-defaults-arch.yml" \
                        "Emulator.py" "batoceraFiles.py" "controllersConfig.py" \
                        "evmapy.py" "unixSettings.py"
    
    # 11. Baixar configurações EmulationStation
    es_files=("es_features_switch.cfg" "es_systems_switch.cfg")
    download_batch_files "/userdata/system/configs/emulationstation" \
                        "system/configs/emulationstation" \
                        "${es_files[@]}"
    
    # 12. Baixar configurações Evmapy
    evmapy_files=("switch.keys")
    download_batch_files "/userdata/system/configs/evmapy" \
                        "system/configs/evmapy" \
                        "${evmapy_files[@]}"
    
    # 13. Baixar scripts de ports
    ports_files=("Sudachi Qlauncher.sh" "Sudachi Qlauncher.sh.keys")
    download_batch_files "/userdata/roms/ports" \
                        "roms/ports" \
                        "${ports_files[@]}"
    
    # 14. Baixar arquivos informativos
    download_file "${BASE_URL}/roms/switch/_info.txt" "/userdata/roms/switch/_info.txt"
    download_file "${BASE_URL}/bios/switch/_info.txt" "/userdata/bios/switch/_info.txt"
    
    # 15. Configurar permissões
    set_permissions
    
    log_success "Instalação base concluída"
    sleep 1
    
    # 16. Executar atualizador
    log_info "Iniciando Switch Updater..."
    echo -e "${X}CARREGANDO ${X}SWITCH UPDATER${X} . . ."
    echo
    
    if run_updater; then
        log_success "Processo de instalação completo"
        return 0
    else
        log_error "Falha no processo de atualização"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# FUNÇÃO PARA MOSTRAR RESULTADO FINAL
# ------------------------------------------------------------------------------
show_final_result() {
    if [[ -e "$EXTRA_DIR/installation" ]]; then
        # Remover marcador de instalação
        rm "$EXTRA_DIR/installation" 2>/dev/null
        
        # Reativar IPv6
        sysctl -w net.ipv6.conf.default.disable_ipv6=0 >/dev/null 2>&1
        sysctl -w net.ipv6.conf.all.disable_ipv6=0 >/dev/null 2>&1
        
        clear
        echo -e "\n\n"
        echo -e "   ${B}INSTALLER BY ${B}"
        echo -e "   ${G}brunnosaint ${G}"
        echo -e "   ${X}$APPNAME INSTALADO${X}"
        echo -e "\n\n"
        
        echo -e "   ${P}INFORMAÇÃO IMPORTANTE! ${P}"
        echo -e "   ${P}USERDATA DEVE ESTAR EM EXT4/BTRFS! PARA A EMULAÇÃO SWITCH FUNCIONAR ${P}"
        echo -e "   ${P}NENHUMA AJUDA SERÁ FORNECIDA SE VOCÊ NÃO ESTIVER EM EXT4/BTRFS! ${P}"
        echo -e "   ${P}SE VOCÊ JÁ ESTÁ EM BTRFS/EXT4 PODE IGNORAR ESTA MENSAGEM ${P}"
        echo -e "\n"
        
        echo -e "   ${X}SE A INSTALAÇÃO/DOWNLOAD FALHAR ${X}"
        echo -e "   ${X}> Adicione manualmente appimage/tar/zip em /userdata/system/switch/appimages${X}"
        echo -e "   ${X}> PACOTE DE ARQUIVOS DISPONÍVEL AQUI: ${X}"
        echo -e "   ${G}> https://1fichier.com/?8furupg6hic0booljbmy ${G}"
        echo -e "   ${X}> Depois execute o SWITCH UPDATER na seção PORTS ${X}"
        echo -e "\n"
        
        echo -e "   ${X}-------------------------------------------------------------------${X}"
        echo -e "   ${X}Coloque suas keys em /userdata/bios/switch/${X}"
        echo -e "   ${X}Firmware *.nca em /userdata/bios/switch/firmware/${X}"
        echo -e "\n"
        
        echo -e "   ${X}-------------------------------------------------------------------${X}"
        echo -e "   ${X}NOTA: Ryujinx Avalonia ${X}"
        echo -e "   ${X}       não funciona mais na versão 42 por enquanto ${X}"
        echo -e "   ${X}       apenas Eden, YuzuEA, Citron, Ryujinx e Sudachi estão disponíveis ${X}"
        echo -e "\n"
        
        echo -e "   ${X}-------------------------------------------------------------------${X}"
        echo -e "   ${X}EM CASO DE PROBLEMAS COM CONTROLES: ${X}"
        echo -e "\n"
        echo -e "   ${X}2) use [autocontroller = off] nas configurações avançadas & ${X}"
        echo -e "   ${X}   configure o controle manualmente em f1-applications ${X}"
        echo -e "\n"
        
        echo -e "   ${X}-------------------------------------------------------------------${X}"
        echo -e "\n"
        echo -e "   ${G}RECARREGUE SUA LISTA DE JOGOS E APROVEITE${G}"
        echo -e "\n"
        echo -e "   ${G}Esta página fechará automaticamente em 10 segundos...${G}"
        echo -e "   ${G}This page will automatically close in 10 seconds...${X}"
        
        # Recarregar lista de jogos
        sleep 10
        curl -s http://127.0.0.1:1234/reloadgames >/dev/null 2>&1 || true
        
        exit 0
    else
        clear
        echo -e "\n\n"
        echo -e "   ${R}Parece que a instalação falhou :(${R}"
        echo -e "\n"
        echo -e "   ${X}Tente executar o script novamente...${X}"
        echo -e "\n\n"
        echo -e "   ${X}Se ainda falhar, tente instalar usando este comando alternativo:"
        echo -e "\n"
        echo -e "   ${X}cd /userdata ; wget -O s batocera.pro/s ; chmod 777 s ; ./s"
        echo -e "\n\n"
        
        # Reativar IPv6
        sysctl -w net.ipv6.conf.default.disable_ipv6=0 >/dev/null 2>&1
        sysctl -w net.ipv6.conf.all.disable_ipv6=0 >/dev/null 2>&1
        
        sleep 5
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# EXECUÇÃO PRINCIPAL
# ------------------------------------------------------------------------------
# Criar diretório de logs
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
mkdir -p "$EXTRA_DIR" 2>/dev/null || true

# Executar instalação
if main_installation; then
    show_final_result
else
    log_error "Instalação falhou"
    # Reativar IPv6 mesmo em caso de falha
    sysctl -w net.ipv6.conf.default.disable_ipv6=0 >/dev/null 2>&1
    sysctl -w net.ipv6.conf.all.disable_ipv6=0 >/dev/null 2>&1
    exit 1
fi