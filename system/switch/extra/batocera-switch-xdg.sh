#!/bin/bash
# ==============================================================================
# batocera-switch-xdg.sh
# Script de configuração XDG (Desktop Group) para batocera-switch
# Configura ambiente desktop com suporte a XFCE e XDG para aplicativos
# ==============================================================================

set -e  # Saída em caso de erro
set -u  # Trata variáveis não definidas como erro

# ------------------------------------------------------------------------------
# CONSTANTES E CONFIGURAÇÕES
# ------------------------------------------------------------------------------
readonly XDG_BASE="/userdata/system/switch/extra/xdg"
readonly LOG_FILE="/userdata/system/switch_xdg_setup.log"
readonly BACKUP_DIR="/userdata/system/switch/backups"

# Cores para output
readonly RED='\033[1;31m'
readonly GREEN='\033[1;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[1;34m'
readonly NC='\033[0m' # No Color

# ------------------------------------------------------------------------------
# FUNÇÕES DE LOG E UTILITÁRIAS
# ------------------------------------------------------------------------------

log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

log_success() {
    log_message "✅ $1"
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    log_message "⚠️  $1"
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    log_message "❌ $1"
    echo -e "${RED}✗${NC} $1"
}

log_info() {
    log_message "ℹ️  $1"
    echo -e "${BLUE}→${NC} $1"
}

# Verifica se o script está sendo executado como root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script requer privilégios de root."
        exit 1
    fi
}

# Verifica filesystem suportado
check_filesystem() {
    log_info "Verificando filesystem..."
    
    local root_partition
    root_partition=$(df -h /userdata | awk 'END {print $1}')
    
    if [[ -z "$root_partition" ]]; then
        log_error "Não foi possível identificar a partição de /userdata"
        return 1
    fi
    
    local fs_type
    fs_type=$(blkid -o value -s TYPE "$root_partition" 2>/dev/null || echo "UNKNOWN")
    fs_type=$(echo "$fs_type" | tr '[:lower:]' '[:upper:]')
    
    case "$fs_type" in
        "EXT4"|"EXT3"|"EXT2"|"BTRFS")
            log_success "Filesystem suportado: $fs_type"
            return 0
            ;;
        *)
            log_error "Filesystem não suportado: $fs_type"
            log_error "Suportados: EXT2/3/4 ou BTRFS"
            return 1
            ;;
    esac
}

# Cria link simbólico seguro
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Verifica se o arquivo fonte existe
    if [[ ! -e "$source" ]]; then
        log_warning "Arquivo fonte não existe: $source"
        return 1
    fi
    
    # Remove link quebrado se existir
    if [[ -L "$target" ]] && [[ ! -e "$target" ]]; then
        rm -f "$target"
    fi
    
    # Cria diretório pai se não existir
    local target_dir
    target_dir=$(dirname "$target")
    mkdir -p "$target_dir" 2>/dev/null || true
    
    # Cria o link simbólico
    if [[ ! -e "$target" ]]; then
        ln -sf "$source" "$target" 2>/dev/null && {
            log_success "Link criado: $target → $source"
            return 0
        } || {
            log_warning "Falha ao criar link: $target"
            return 1
        }
    else
        log_info "Já existe: $target"
        return 0
    fi
}

# Processa diretório criando links simbólicos
process_directory() {
    local source_dir="$1"
    local target_dir="$2"
    
    if [[ ! -d "$source_dir" ]]; then
        log_warning "Diretório fonte não existe: $source_dir"
        return 1
    fi
    
    log_info "Processando: $source_dir → $target_dir"
    
    # Cria diretório de destino se não existir
    mkdir -p "$target_dir" 2>/dev/null || true
    
    local count=0
    local errors=0
    
    # Processa cada item no diretório
    for item in "$source_dir"/*; do
        if [[ -e "$item" ]]; then
            local item_name
            item_name=$(basename "$item")
            local target_path="$target_dir/$item_name"
            
            if [[ -f "$item" ]]; then
                create_symlink "$item" "$target_path" || ((errors++))
                ((count++))
            elif [[ -d "$item" ]]; then
                # Para diretórios, cria link direto
                create_symlink "$item" "$target_path" || ((errors++))
                ((count++))
            fi
        fi
    done
    
    log_info "Processados: $count itens, $errors erros"
    return $errors
}

# Configura módulos Python
setup_python_modules() {
    log_info "Configurando módulos Python..."
    
    # Versões do Python a verificar
    local python_versions=("3.11" "3.10" "3.9" "3.8")
    local source_xdg="$XDG_BASE/usr/lib/python3/dist-packages/xdg"
    
    if [[ ! -d "$source_xdg" ]]; then
        log_warning "Módulos Python XDG não encontrados: $source_xdg"
        return 1
    fi
    
    for version in "${python_versions[@]}"; do
        local site_packages="/usr/lib/python${version}/site-packages"
        
        if [[ -d "$site_packages" ]]; then
            log_info "Python ${version} encontrado, instalando módulos..."
            
            # Copia módulos XDG
            if [[ ! -d "$site_packages/xdg" ]]; then
                cp -r "$source_xdg" "$site_packages/" && \
                log_success "Módulos XDG instalados para Python ${version}"
                
                # Atualiza cache de bytecode se necessário
                if [[ -d "$site_packages/xdg/__pycache__" ]]; then
                    cd "$site_packages/xdg/__pycache__" 2>/dev/null || continue
                    
                    # Renomeia arquivos de cache para versão específica
                    for cache_file in *-*.pyc; do
                        if [[ -f "$cache_file" ]]; then
                            local new_name
                            new_name=$(echo "$cache_file" | sed "s/-[0-9]\{1,\}\./-${version//./}\./")
                            if [[ "$cache_file" != "$new_name" ]]; then
                                mv -f "$cache_file" "$new_name" 2>/dev/null || true
                            fi
                        fi
                    done
                    cd - >/dev/null 2>&1
                fi
            else
                log_info "Módulos XDG já existem para Python ${version}"
            fi
        fi
    done
}

# Configura ambiente XFCE
setup_xfce() {
    log_info "Configurando ambiente XFCE..."
    
    # Helpers do XFCE
    local xfce_helpers_dir="/userdata/system/.local/share/xfce4/helpers"
    mkdir -p "$xfce_helpers_dir" 2>/dev/null || true
    
    local source_helpers="$XDG_BASE/local/share/xfce4/helpers"
    if [[ -d "$source_helpers" ]]; then
        for helper in "$source_helpers"/*; do
            if [[ -f "$helper" ]]; then
                local helper_name
                helper_name=$(basename "$helper")
                if [[ ! -e "$xfce_helpers_dir/$helper_name" ]]; then
                    cp "$helper" "$xfce_helpers_dir/" && \
                    log_success "Helper instalado: $helper_name"
                fi
            fi
        done
    fi
    
    # Configuração XFCE
    local xfce_config_dir="/userdata/system/.config/xfce4"
    mkdir -p "$xfce_config_dir" 2>/dev/null || true
    
    local helpers_rc_source="$XDG_BASE/config/helpers.rc"
    local helpers_rc_target="$xfce_config_dir/helpers.rc"
    
    if [[ -f "$helpers_rc_source" ]] && [[ ! -e "$helpers_rc_target" ]]; then
        cp "$helpers_rc_source" "$helpers_rc_target" && \
        log_success "Configuração XFCE instalada"
    fi
    
    # Configuração mimeapps
    local mimeapps_source="$XDG_BASE/config/mimeapps.list"
    local mimeapps_target="/userdata/system/.config/mimeapps.list"
    
    if [[ -f "$mimeapps_source" ]] && [[ ! -e "$mimeapps_target" ]]; then
        cp "$mimeapps_source" "$mimeapps_target" && \
        log_success "Configuração MIME instalada"
    fi
}

# Configura variáveis de ambiente
setup_environment() {
    log_info "Configurando variáveis de ambiente..."
    
    # Adiciona diretórios ao PATH
    export PATH="/usr/libexec:/usr/share/applications:${PATH}"
    
    # Configura XDG
    export XDG_DATA_DIRS="/usr/share/applications:${XDG_DATA_DIRS:-/usr/share}"
    export XDG_CURRENT_DESKTOP="XFCE"
    export DESKTOP_SESSION="XFCE"
    
    # Configurações adicionais
    export GTK_USE_PORTAL=1
    export QT_QPA_PLATFORMTHEME=gtk3
    
    log_success "Variáveis de ambiente configuradas"
    
    # Salva variáveis em arquivo para persistência
    cat > /userdata/system/switch/xdg_env.sh << EOF
#!/bin/bash
# Variáveis de ambiente XDG - Gerado automaticamente
export PATH="/usr/libexec:/usr/share/applications:\$PATH"
export XDG_DATA_DIRS="/usr/share/applications:\${XDG_DATA_DIRS}"
export XDG_CURRENT_DESKTOP="XFCE"
export DESKTOP_SESSION="XFCE"
export GTK_USE_PORTAL=1
export QT_QPA_PLATFORMTHEME=gtk3
EOF
    
    chmod +x /userdata/system/switch/xdg_env.sh
}

# ------------------------------------------------------------------------------
# FUNÇÃO PRINCIPAL
# ------------------------------------------------------------------------------
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  CONFIGURADOR XDG PARA BATOCERA-SWITCH ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    # Inicia log
    log_message "=== Iniciando configuração XDG ==="
    
    # Verificações iniciais
    check_root
    
    if [[ ! -d "$XDG_BASE" ]]; then
        log_error "Diretório XDG não encontrado: $XDG_BASE"
        exit 1
    fi
    
    if ! check_filesystem; then
        log_error "Filesystem não suportado. Abortando."
        exit 1
    fi
    
    log_success "Todos os pré-requisitos verificados"
    
    # --------------------------------------------------------------------------
    # 1. CONFIGURAÇÃO DE BINÁRIOS
    # --------------------------------------------------------------------------
    log_info "Configurando binários..."
    
    # /usr/bin
    process_directory "$XDG_BASE/usr/bin" "/usr/bin"
    
    # /usr/libexec
    process_directory "$XDG_BASE/usr/libexec" "/usr/libexec"
    
    # Links adicionais de libexec para /usr/bin
    if [[ -d "$XDG_BASE/usr/libexec" ]]; then
        for file in "$XDG_BASE/usr/libexec"/*; do
            if [[ -f "$file" ]]; then
                local file_name
                file_name=$(basename "$file")
                create_symlink "$file" "/usr/bin/$file_name"
            fi
        done
    fi
    
    # --------------------------------------------------------------------------
    # 2. CONFIGURAÇÃO DE BIBLIOTECAS
    # --------------------------------------------------------------------------
    log_info "Configurando bibliotecas..."
    
    # x86_64-linux-gnu
    local lib64_dir="/usr/lib/x86_64-linux-gnu"
    if [[ ! -d "$lib64_dir" ]]; then
        mkdir -p "$lib64_dir" 2>/dev/null || true
    fi
    
    # Links para bibliotecas específicas
    local lib_links=("perl" "perl5" "perl-base" "xfce4")
    for lib in "${lib_links[@]}"; do
        local source_lib="$XDG_BASE/usr/lib/x86_64-linux-gnu/$lib"
        if [[ -e "$source_lib" ]]; then
            create_symlink "$source_lib" "$lib64_dir/$lib"
            create_symlink "$source_lib" "/usr/lib/$lib"
        fi
    done
    
    # Systemd
    process_directory "$XDG_BASE/usr/lib/systemd" "/usr/lib"
    
    # Bibliotecas adicionais
    process_directory "$XDG_BASE/usr/lib/x86_64-linux-gnu" "/usr/lib"
    process_directory "$XDG_BASE/lib64" "/usr/lib"
    
    # --------------------------------------------------------------------------
    # 3. MÓDULOS PYTHON
    # --------------------------------------------------------------------------
    setup_python_modules
    
    # --------------------------------------------------------------------------
    # 4. ARQUIVOS COMPARTILHADOS
    # --------------------------------------------------------------------------
    log_info "Configurando arquivos compartilhados..."
    
    if [[ -d "$XDG_BASE/usr/share" ]]; then
        # Usa rsync para copiar preservando links simbólicos
        rsync -au "$XDG_BASE/usr/share/" "/usr/share/" 2>/dev/null || \
        cp -r "$XDG_BASE/usr/share/"* "/usr/share/" 2>/dev/null || \
        log_warning "Falha ao copiar arquivos share"
        log_success "Arquivos share instalados"
    fi
    
    # --------------------------------------------------------------------------
    # 5. CONFIGURAÇÕES XFCE E MIME
    # --------------------------------------------------------------------------
    setup_xfce
    
    # Filemanager desktop
    if [[ -f "$XDG_BASE/config/filemanager.desktop" ]]; then
        cp -f "$XDG_BASE/config/filemanager.desktop" "/usr/share/applications/" 2>/dev/null || true
    fi
    
    if [[ -d "$XDG_BASE/config/filemanager" ]]; then
        cp -rf "$XDG_BASE/config/filemanager" "/usr/bin/" 2>/dev/null || true
    fi
    
    # --------------------------------------------------------------------------
    # 6. VARIÁVEIS DE AMBIENTE
    # --------------------------------------------------------------------------
    setup_environment
    
    # --------------------------------------------------------------------------
    # CONCLUSÃO
    # --------------------------------------------------------------------------
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  CONFIGURAÇÃO XDG CONCLUÍDA COM SUCESSO  ${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}Resumo:${NC}"
    echo -e "  • Binários configurados em /usr/bin e /usr/libexec"
    echo -e "  • Bibliotecas instaladas"
    echo -e "  • Módulos Python configurados"
    echo -e "  • Ambiente XFCE preparado"
    echo -e "  • Variáveis de ambiente definidas"
    echo ""
    echo -e "${YELLOW}Variáveis configuradas:${NC}"
    echo -e "  XDG_CURRENT_DESKTOP=XFCE"
    echo -e "  DESKTOP_SESSION=XFCE"
    echo -e "  PATH atualizado com /usr/libexec"
    echo ""
    echo -e "${BLUE}Log completo em:${NC} $LOG_FILE"
    echo ""
    
    log_message "=== Configuração XDG concluída com sucesso ==="
    
    return 0
}

# ------------------------------------------------------------------------------
# EXECUÇÃO PRINCIPAL
# ------------------------------------------------------------------------------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Cria diretório de backups
    mkdir -p "$BACKUP_DIR" 2>/dev/null || true
    
    # Executa função principal
    if main; then
        exit 0
    else
        log_error "Falha na configuração XDG"
        exit 1
    fi
fi