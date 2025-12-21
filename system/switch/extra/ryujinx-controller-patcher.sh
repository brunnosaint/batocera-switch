#!/usr/bin/env bash
# ============================================
# RYUJINX CONTROLLER PATCHER FOR BATOCERA-SWITCH
# ============================================
# Este script atualiza o controlador padrão no gerador Ryujinx
# para usar o controlador configurado pelo usuário no Ryujinx/Avalonia
# ============================================

clear

# Cores para output
readonly G='\033[1;32m'   # Verde
readonly R='\033[1;31m'   # Vermelho
readonly Y='\033[1;33m'   # Amarelo
readonly B='\033[1;34m'   # Azul
readonly X='\033[0m'      # Reset

# Caminhos importantes
readonly RYUJINX_CONFIG="/userdata/system/configs/Ryujinx/Config.json"
readonly RYUJINX_GENERATOR="/userdata/system/switch/configgen/generators/ryujinx/ryujinxMainlineGenerator.py"
readonly SCRIPT_PATH="/userdata/system/switch/extra/ryujinx-controller-patcher.sh"

# Função para mostrar cabeçalho
show_header() {
    echo -e "${R}===================================================${X}"
    echo -e "${R}    RYUJINX CONTROLLER PATCHER FOR BATOCERA-SWITCH ${X}"
    echo -e "${R}===================================================${X}"
    echo -e "${X}Caminho do script: ${Y}$SCRIPT_PATH${X}"
    echo -e "${R}---------------------------------------------------${X}"
}

# Função para mostrar instruções detalhadas
show_instructions() {
    echo -e "${Y}COMO USAR:${X}"
    echo -e "${B}1.${X}  Abra o Ryujinx (Avalonia) em [F1] → [APPS]"
    echo -e "${B}2.${X}  Vá em 'Options' → 'Settings' ou 'Settings' (Configurações)"
    echo -e "${B}3.${X}  Selecione a aba 'Input'"
    echo -e "${B}4.${X}  Configure seu controle nas opções disponíveis:"
    echo -e "     • Player 1 (Padão)"
    echo -e "     • Ou em 'Configure Input'"
    echo -e "${B}5.${X}  Clique em 'Save' ou 'Apply' para salvar"
    echo -e "${B}6.${X}  Feche o Ryujinx e execute este script"
    echo -e "${R}---------------------------------------------------${X}"
    echo
    echo -e "${Y}NOTA:${X} É importante ${B}fechar o Ryujinx${X} antes de executar este script,"
    echo -e "      pois o arquivo de configuração pode estar bloqueado."
    echo
}

# Função para extrair o ID do controle do Ryujinx
extract_controller_id() {
    if [[ ! -f "$RYUJINX_CONFIG" ]]; then
        echo -e "${R}ERRO: Arquivo de configuração do Ryujinx não encontrado!${X}"
        echo -e "${X}Caminho: $RYUJINX_CONFIG"
        echo
        echo -e "${Y}Certifique-se de:${X}"
        echo -e "1. O Ryujinx foi aberto pelo menos uma vez"
        echo -e "2. Você configurou um controle nas configurações"
        echo -e "3. Salvou as configurações"
        echo
        return 1
    fi
    
    # Tentar extrair o ID do controle do arquivo Config.json
    # O formato pode variar dependendo da versão do Ryujinx
    local controller_id
    
    # Método 1: Procurar por "id": no contexto de controles
    controller_id=$(grep -A5 -B5 '"input"' "$RYUJINX_CONFIG" | grep '"id":' | head -1 | cut -d '"' -f4)
    
    # Método 2: Procurar diretamente
    if [[ -z "$controller_id" ]] || [[ "$controller_id" == "0" ]]; then
        controller_id=$(grep '"id":' "$RYUJINX_CONFIG" | head -1 | cut -d '"' -f4)
    fi
    
    # Método 3: Procurar por "guid" (formato alternativo)
    if [[ -z "$controller_id" ]] || [[ "$controller_id" == "0" ]]; then
        controller_id=$(grep -i 'guid' "$RYUJINX_CONFIG" | head -1 | cut -d '"' -f4 | awk '{print $1}')
    fi
    
    # Limpar espaços em branco
    controller_id=$(echo "$controller_id" | xargs)
    
    echo "$controller_id"
}

# Função para verificar se já está patchado
is_already_patched() {
    local controller_id="$1"
    
    if [[ ! -f "$RYUJINX_GENERATOR" ]]; then
        echo -e "${R}ERRO: Gerador Ryujinx não encontrado!${X}"
        echo -e "${X}Caminho: $RYUJINX_GENERATOR"
        echo -e "${Y}Certifique-se de que o batocera-switch está instalado.${X}"
        echo
        return 2
    fi
    
    # Extrair o ID atual do gerador
    local current_id=$(grep "cvalue\['id'\]" "$RYUJINX_GENERATOR" | head -1 | sed "s/.*= //g" | tr -d ' "' 2>/dev/null)
    
    # Verificar se o ID extraído corresponde ao ID do controle
    if [[ "$current_id" == "$controller_id" ]] && [[ -n "$controller_id" ]]; then
        return 0  # Já está patchado
    else
        return 1  # Precisa patchar
    fi
}

# Função para fazer backup do arquivo
create_backup() {
    local file="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${file}.backup.${timestamp}"
    
    if [[ -f "$file" ]]; then
        cp "$file" "$backup_file" 2>/dev/null && {
            echo -e "${B}Backup criado:${X} ${Y}$backup_file${X}"
            return 0
        } || {
            echo -e "${R}Aviso: Não foi possível criar backup${X}"
            return 1
        }
    fi
    return 0
}

# Função principal
main() {
    show_header
    show_instructions
    
    # Verificar se o Ryujinx foi configurado
    echo -e "${Y}Verificando configuração do Ryujinx...${X}"
    echo
    
    local controller_id=$(extract_controller_id)
    
    # Caso 1: Nenhum controle configurado
    if [[ -z "$controller_id" ]] || [[ "$controller_id" == "0" ]]; then
        echo -e "${R}❌ NENHUM CONTROLE CONFIGURADO ENCONTRADO!${X}"
        echo
        echo -e "${Y}Siga estes passos para configurar:${X}"
        echo -e "1. Abra o Ryujinx/Avalonia (F1 → APPS)"
        echo -e "2. Vá para 'Settings' (Configurações)"
        echo -e "3. Selecione a aba 'Input' (Entrada)"
        echo -e "4. Configure seu controle (normalmente 'Player 1')"
        echo -e "5. Clique em 'Save' (Salvar)"
        echo -e "6. Feche completamente o Ryujinx"
        echo -e "7. Execute este script novamente"
        echo
        echo -e "${Y}Dica:${X} Se não encontrar opções de controle,"
        echo -e "      verifique se algum controle está conectado ao sistema."
        echo
        exit 1
    fi
    
    # Caso 2: Controle encontrado
    echo -e "${G}✓ Controle encontrado!${X}"
    echo -e "${B}ID do controle:${X} ${Y}$controller_id${X}"
    echo
    
    # Verificar se o gerador existe
    if [[ ! -f "$RYUJINX_GENERATOR" ]]; then
        echo -e "${R}ERRO: Gerador Ryujinx não encontrado!${X}"
        echo -e "${X}Caminho: $RYUJINX_GENERATOR"
        echo -e "${Y}Certifique-se de que:${X}"
        echo -e "1. O batocera-switch está instalado"
        echo -e "2. O diretório /userdata/system/switch/ existe"
        echo -e "3. Você tem permissões de leitura/escrita"
        echo
        exit 1
    fi
    
    # Verificar se já está patchado
    if is_already_patched "$controller_id"; then
        local status_code=$?
        
        if [[ $status_code -eq 0 ]]; then
            echo -e "${G}===================================================${X}"
            echo -e "${G}✓ O GERADOR RYUJINX JÁ ESTÁ CONFIGURADO!${X}"
            echo -e "${G}===================================================${X}"
            echo
            echo -e "${X}O controle já está definido como padrão no gerador."
            echo -e "${Y}ID configurado:${X} ${G}$controller_id${X}"
            echo
            echo -e "${X}Nenhuma alteração necessária."
            echo
            exit 0
        else
            # is_already_patched retornou erro 2 (arquivo não encontrado)
            exit 1
        fi
    fi
    
    # Caso 3: Precisa aplicar o patch
    echo -e "${Y}Aplicando patch no gerador Ryujinx...${X}"
    echo
    
    # Criar backup do arquivo original
    create_backup "$RYUJINX_GENERATOR"
    
    # Preparar as strings para substituição
    local search_pattern="^[[:space:]]*cvalue\['id'\] =.*$"
    local replacement_line="                cvalue['id'] = \"$controller_id\""
    
    # Contar quantas linhas correspondem ao padrão
    local match_count=$(grep -c "$search_pattern" "$RYUJINX_GENERATOR")
    
    if [[ $match_count -eq 0 ]]; then
        echo -e "${Y}AVISO: Padrão não encontrado no arquivo.${X}"
        echo -e "${X}Tentando localizar manualmente..."
        
        # Tentar encontrar variações do padrão
        local alt_pattern1="cvalue\['id'\]"
        local alt_pattern2="cvalue\[.*id.*\]"
        
        if grep -q "$alt_pattern1" "$RYUJINX_GENERATOR"; then
            echo -e "${G}Padrão alternativo encontrado.${X}"
        else
            echo -e "${R}ERRO: Não foi possível encontrar o código a ser modificado.${X}"
            echo -e "${Y}O formato do arquivo pode ter mudado.${X}"
            echo
            echo -e "${B}Tentativa manual:${X}"
            echo -e "1. Abra o arquivo: $RYUJINX_GENERATOR"
            echo -e "2. Procure por: cvalue['id'] ="
            echo -e "3. Substitua a linha inteira por:"
            echo -e "   $replacement_line"
            echo -e "4. Salve o arquivo"
            echo
            exit 1
        fi
    fi
    
    # Aplicar a substituição
    echo -e "${B}Aplicando alteração...${X}"
    
    if sed -i "s|$search_pattern|$replacement_line|g" "$RYUJINX_GENERATOR"; then
        # Verificar se a alteração foi aplicada com sucesso
        if grep -q "cvalue\['id'\] = \"$controller_id\"" "$RYUJINX_GENERATOR"; then
            echo -e "${G}===================================================${X}"
            echo -e "${G}✓ PATCH APLICADO COM SUCESSO!${X}"
            echo -e "${G}===================================================${X}"
            echo
            echo -e "${X}${B}Alteração realizada:${X}"
            echo -e "${Y}Antes:${X} cvalue['id'] = (gerado automaticamente)"
            echo -e "${Y}Depois:${X} cvalue['id'] = \"$controller_id\""
            echo
            echo -e "${B}ID do controle:${X}"
            echo -e "${G}$controller_id${X}"
            echo
            echo -e "${Y}O gerador Ryujinx agora usará este controle por padrão.${X}"
            echo -e "${Y}Execute seus jogos normalmente pelo EmulationStation.${X}"
            echo
        else
            echo -e "${R}❌ ERRO: A alteração não foi aplicada corretamente.${X}"
            echo -e "${Y}Tentativa manual necessária.${X}"
            echo
            exit 1
        fi
    else
        echo -e "${R}❌ ERRO AO APLICAR O PATCH!${X}"
        echo -e "${Y}Possíveis causas:${X}"
        echo -e "• Permissões insuficientes"
        echo -e "• Arquivo em uso"
        echo -e "• Disco cheio"
        echo
        exit 1
    fi
    
    echo -e "${R}---------------------------------------------------${X}"
    echo -e "${G}✓ Processo concluído com sucesso!${X}"
    echo -e "${R}---------------------------------------------------${X}"
    echo
    echo -e "${Y}Próximos passos:${X}"
    echo -e "1. Os jogos do Nintendo Switch agora usarão este controle"
    echo -e "2. Execute os jogos normalmente pelo EmulationStation"
    echo -e "3. Se precisar alterar o controle, repita o processo"
    echo
}

# Tratamento de erro global
handle_error() {
    echo -e "${R}===================================================${X}"
    echo -e "${R}ERRO CRÍTICO${X}"
    echo -e "${R}===================================================${X}"
    echo -e "${Y}O script encontrou um erro inesperado.${X}"
    echo
    echo -e "${B}Informações para troubleshooting:${X}"
    echo -e "• Script: $SCRIPT_PATH"
    echo -e "• Hora: $(date)"
    echo -e "• Usuário: $(whoami)"
    echo
    exit 1
}

# Configurar trap para erros
trap 'handle_error' ERR

# Executar função principal
main "$@"