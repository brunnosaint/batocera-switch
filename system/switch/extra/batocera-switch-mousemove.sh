#!/bin/bash
# ==============================================================================
# BATOCERA-SWITCH-MOUSEMOVE.SH
# Script para mover o cursor do mouse para fora da área de jogo
# Útil para emuladores que exibem cursor durante o jogo
# ==============================================================================

set -e  # Saída em caso de erro crítico
set -u  # Trata variáveis não definidas como erro

# ------------------------------------------------------------------------------
# CONSTANTES E CONFIGURAÇÕES
# ------------------------------------------------------------------------------
readonly LIB_XDO="/lib/libxdo.so.3"
readonly LINK_XDO="/userdata/system/switch/extra/batocera-switch-libxdo.so.3"
readonly XDOTOOL_BIN="/usr/bin/xdotool"
readonly LINK_XDOTOOL="/userdata/system/switch/extra/batocera-switch-xdotool"
readonly LOG_FILE="/userdata/system/switch_mousemove.log"

# ------------------------------------------------------------------------------
# FUNÇÕES DE LOG
# ------------------------------------------------------------------------------

log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

log_info() {
    log_message "INFO: $1"
}

log_error() {
    log_message "ERROR: $1"
    echo "Erro: $1" >&2
}

# ------------------------------------------------------------------------------
# FUNÇÕES UTILITÁRIAS
# ------------------------------------------------------------------------------

# Verifica se o script está sendo executado em ambiente gráfico
check_graphical_environment() {
    if [[ -z "$DISPLAY" ]]; then
        log_error "Ambiente gráfico não detectado (DISPLAY não definido)"
        return 1
    fi
    
    if ! command -v xrandr >/dev/null 2>&1; then
        log_error "xrandr não encontrado. Certifique-se de estar em ambiente X11"
        return 1
    fi
    
    return 0
}

# Obtém resolução da tela principal
get_screen_resolution() {
    local resolution
    
    # Método 1: Usar xrandr para obter resolução da tela ativa
    resolution=$(xrandr --current 2>/dev/null | grep -E "\*\+" | head -n1 | awk '{print $1}')
    
    # Método 2: Alternativa se o primeiro falhar
    if [[ -z "$resolution" ]]; then
        resolution=$(xrandr --current 2>/dev/null | grep "+" | tail -n1 | awk '{print $1}')
    fi
    
    # Método 3: Alternativa mais básica
    if [[ -z "$resolution" ]]; then
        resolution=$(xrandr --current 2>/dev/null | grep -E "[0-9]+x[0-9]+" | head -n1 | awk '{print $1}')
    fi
    
    echo "$resolution"
}

# Valida resolução obtida
validate_resolution() {
    local resolution="$1"
    
    # Verificar formato básico (ex: 1920x1080)
    if [[ ! "$resolution" =~ ^[0-9]+x[0-9]+$ ]]; then
        log_error "Formato de resolução inválido: $resolution"
        return 1
    fi
    
    local width=$(echo "$resolution" | cut -d "x" -f1)
    local height=$(echo "$resolution" | cut -d "x" -f2)
    
    # Verificar valores razoáveis para resolução
    if [[ "$width" -lt 640 ]] || [[ "$width" -gt 7680 ]]; then
        log_warning "Largura de tela fora do comum: $width pixels"
    fi
    
    if [[ "$height" -lt 480 ]] || [[ "$height" -gt 4320 ]]; then
        log_warning "Altura de tela fora do comum: $height pixels"
    fi
    
    echo "$width $height"
    return 0
}

# Configura dependências (cria links simbólicos)
setup_dependencies() {
    log_info "Configurando dependências..."
    
    # Verificar se os arquivos fonte existem
    if [[ ! -f "$LINK_XDO" ]]; then
        log_error "Arquivo libxdo não encontrado: $LINK_XDO"
        return 1
    fi
    
    if [[ ! -f "$LINK_XDOTOOL" ]]; then
        log_error "Arquivo xdotool não encontrado: $LINK_XDOTOOL"
        return 1
    fi
    
    # Criar diretório para lib se não existir
    local lib_dir=$(dirname "$LIB_XDO")
    if [[ ! -d "$lib_dir" ]]; then
        mkdir -p "$lib_dir" 2>/dev/null || {
            log_error "Não foi possível criar diretório: $lib_dir"
            return 1
        }
    fi
    
    # Criar link para libxdo
    if [[ ! -L "$LIB_XDO" ]] || [[ ! -e "$LIB_XDO" ]]; then
        ln -sf "$LINK_XDO" "$LIB_XDO" 2>/dev/null && \
        log_info "Link criado: $LIB_XDO → $LINK_XDO" || {
            log_error "Falha ao criar link para libxdo"
            return 1
        }
    fi
    
    # Criar link para xdotool
    if [[ ! -L "$XDOTOOL_BIN" ]] || [[ ! -e "$XDOTOOL_BIN" ]]; then
        ln -sf "$LINK_XDOTOOL" "$XDOTOOL_BIN" 2>/dev/null && \
        log_info "Link criado: $XDOTOOL_BIN → $LINK_XDOTOOL" || {
            log_error "Falha ao criar link para xdotool"
            return 1
        }
    fi
    
    # Verificar se xdotool está acessível
    if ! command -v xdotool >/dev/null 2>&1; then
        log_error "xdotool não está disponível após configuração"
        return 1
    fi
    
    log_info "Dependências configuradas com sucesso"
    return 0
}

# Move o cursor do mouse
move_mouse_cursor() {
    local width="$1"
    local height="$2"
    
    log_info "Movendo cursor para posição ($width, $height)"
    
    # Tentar mover para canto inferior direito
    if xdotool mousemove --sync "$width" "$height" 2>/dev/null; then
        log_info "Cursor movido para canto inferior direito ($width, $height)"
        return 0
    else
        log_warning "Falha ao mover para ($width, $height), tentando canto superior esquerdo"
        
        # Fallback: mover para canto superior esquerdo
        if xdotool mousemove --sync 0 0 2>/dev/null; then
            log_info "Cursor movido para canto superior esquerdo (0, 0)"
            return 0
        else
            log_error "Falha ao mover cursor do mouse"
            return 1
        fi
    fi
}

# Função principal
main() {
    log_info "=== Iniciando script de movimento do mouse ==="
    
    # Verificar ambiente gráfico
    if ! check_graphical_environment; then
        log_error "Script requer ambiente gráfico X11"
        return 1
    fi
    
    # Configurar dependências
    if ! setup_dependencies; then
        log_error "Falha na configuração de dependências"
        return 1
    fi
    
    # Obter resolução da tela
    local resolution
    resolution=$(get_screen_resolution)
    
    if [[ -z "$resolution" ]]; then
        log_error "Não foi possível detectar a resolução da tela"
        
        # Tentar fallback com valores padrão
        log_info "Usando resolução padrão 1920x1080 como fallback"
        resolution="1920x1080"
    else
        log_info "Resolução detectada: $resolution"
    fi
    
    # Validar e extrair dimensões
    local dimensions
    if dimensions=$(validate_resolution "$resolution"); then
        local width height
        read width height <<< "$dimensions"
        
        # Ajustar posição para mover para fora da área visível
        # Subtrair 1 pixel para garantir que fique fora da tela
        if [[ "$width" -gt 1 ]] && [[ "$height" -gt 1 ]]; then
            width=$((width - 1))
            height=$((height - 1))
        fi
        
        # Mover cursor
        if move_mouse_cursor "$width" "$height"; then
            log_info "Script executado com sucesso"
            return 0
        else
            return 1
        fi
    else
        # Fallback: mover para (0,0)
        log_info "Usando posição de fallback (0, 0)"
        move_mouse_cursor 0 0
    fi
}

# ------------------------------------------------------------------------------
# EXECUÇÃO PRINCIPAL
# ------------------------------------------------------------------------------
# Criar diretório de log se não existir
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

# Executar função principal
if main; then
    exit 0
else
    log_error "Script falhou"
    exit 1
fi