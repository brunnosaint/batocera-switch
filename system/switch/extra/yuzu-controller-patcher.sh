#!/usr/bin/env bash
# ============================================
# YUZU CONTROLLER PATCHER FOR BATOCERA-SWITCH
# ============================================
# Este script atualiza o controlador padrão no gerador Yuzu
# para usar o controlador configurado pelo usuário
# ============================================

clear

# Cores para output
G='\033[1;32m'
R='\033[1;31m'
Y='\033[1;33m'
X='\033[0m'
B='\033[1;34m'

# Caminhos importantes
YUZU_CONFIG="/userdata/system/configs/yuzu/qt-config.ini"
YUZU_GENERATOR="/userdata/system/switch/configgen/generators/yuzu/yuzuMainlineGenerator.py"
SCRIPT_PATH="/userdata/system/switch/extra/yuzu-controller-patcher.sh"

# Função para mostrar cabeçalho
show_header() {
    echo -e "${R}===================================================${X}"
    echo -e "${R}    YUZU CONTROLLER PATCHER FOR BATOCERA-SWITCH    ${X}"
    echo -e "${R}===================================================${X}"
    echo -e "${X}Caminho do script: ${Y}$SCRIPT_PATH${X}"
    echo -e "${R}---------------------------------------------------${X}"
}

# Função para mostrar instruções
show_instructions() {
    echo -e "${Y}COMO USAR:${X}"
    echo -e "${B}1.${X}  Abra o Yuzu em [F1] → [APPS]"
    echo -e "${B}2.${X}  Vá em Emulation → Configure..."
    echo -e "${B}3.${X}  Selecione 'Controls' na barra lateral"
    echo -e "${B}4.${X}  Escolha seu controle nos dispositivos de entrada"
    echo -e "${B}5.${X}  Configure os botões e clique em 'Apply'/'Save'"
    echo -e "${B}6.${X}  Feche o Yuzu e execute este script"
    echo -e "${R}---------------------------------------------------${X}"
    echo
}

# Função para extrair o GUID do controle
extract_controller_guid() {
    if [[ ! -f "$YUZU_CONFIG" ]]; then
        echo -e "${R}ERRO: Arquivo de configuração do Yuzu não encontrado!${X}"
        echo -e "${X}Caminho: $YUZU_CONFIG"
        echo
        return 1
    fi
    
    # Extrair o primeiro GUID encontrado no arquivo de configuração
    local guid=$(grep -m1 'guid:' "$YUZU_CONFIG" | sed 's/^.*guid://g' | cut -d "," -f1)
    
    # Limpar espaços em branco
    guid=$(echo "$guid" | xargs)
    
    echo "$guid"
}

# Função para verificar se o patcher já está aplicado
is_already_patched() {
    local current_guid="$1"
    local patched_guid=$(grep -m1 'inputguid = "' "$YUZU_GENERATOR" 2>/dev/null | sed 's/^.*inputguid = "//g' | sed 's/"//g')
    
    if [[ "$patched_guid" == "$current_guid" ]] && [[ -n "$current_guid" ]]; then
        return 0  # Já está patchado
    else
        return 1  # Precisa patchar
    fi
}

# Função principal
main() {
    show_header
    show_instructions
    
    # Verificar se o Yuzu foi configurado
    echo -e "${Y}Verificando configuração do Yuzu...${X}"
    echo
    
    local controller_guid=$(extract_controller_guid)
    
    # Caso 1: Nenhum controle configurado
    if [[ -z "$controller_guid" ]] || [[ "$controller_guid" == "0" ]]; then
        echo -e "${R}❌ NENHUM CONTROLE CONFIGURADO ENCONTRADO!${X}"
        echo
        echo -e "${Y}Siga estes passos:${X}"
        echo -e "1. Abra o Yuzu (F1 → APPS)"
        echo -e "2. Vá em: Emulation → Configure..."
        echo -e "3. Selecione 'Controls' na barra lateral"
        echo -e "4. Escolha seu controle em 'Input Devices'"
        echo -e "5. Configure os botões e clique em 'Apply'"
        echo -e "6. Feche o Yuzu e execute este script novamente"
        echo
        echo -e "${R}Execute o script novamente após configurar o controle.${X}"
        echo
        exit 1
    fi
    
    # Caso 2: Controle encontrado
    echo -e "${G}✓ Controle encontrado!${X}"
    echo -e "${B}GUID:${X} ${Y}$controller_guid${X}"
    echo
    
    # Verificar se o gerador Yuzu existe
    if [[ ! -f "$YUZU_GENERATOR" ]]; then
        echo -e "${R}ERRO: Gerador Yuzu não encontrado!${X}"
        echo -e "${X}Caminho: $YUZU_GENERATOR"
        echo -e "${Y}Certifique-se de que o batocera-switch está instalado.${X}"
        echo
        exit 1
    fi
    
    # Verificar se já está patchado
    if is_already_patched "$controller_guid"; then
        echo -e "${G}===================================================${X}"
        echo -e "${G}✓ O GERADOR YUZU JÁ ESTÁ CONFIGURADO!${X}"
        echo -e "${G}===================================================${X}"
        echo
        echo -e "${X}O controle já está definido como padrão no gerador."
        echo -e "${Y}GUID configurado:${X} ${G}$controller_guid${X}"
        echo
        echo -e "${X}Nenhuma alteração necessária."
        echo
        exit 0
    fi
    
    # Caso 3: Precisa aplicar o patch
    echo -e "${Y}Aplicando patch no gerador Yuzu...${X}"
    echo
    
    # Backup do arquivo original
    backup_file="${YUZU_GENERATOR}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$YUZU_GENERATOR" "$backup_file"
    echo -e "${B}Backup criado:${X} ${Y}$backup_file${X}"
    
    # Aplicar o patch
    local target_line="inputguid = controller.guid"
    local replacement_line="                inputguid = \"$controller_guid\""
    
    # Contar quantas linhas serão modificadas
    local match_count=$(grep -c "$target_line" "$YUZU_GENERATOR")
    
    if [[ $match_count -eq 0 ]]; then
        echo -e "${R}AVISO: Linha de GUID não encontrada no gerador.${X}"
        echo -e "${Y}O formato do arquivo pode ter mudado.${X}"
        echo
    fi
    
    # Aplicar a substituição
    sed -i "s|^.*$target_line|$replacement_line|g" "$YUZU_GENERATOR"
    
    # Verificar se a alteração foi aplicada
    if grep -q "inputguid = \"$controller_guid\"" "$YUZU_GENERATOR"; then
        echo -e "${G}===================================================${X}"
        echo -e "${G}✓ PATCH APLICADO COM SUCESSO!${X}"
        echo -e "${G}===================================================${X}"
        echo
        echo -e "${X}${B}Alteração realizada:${X}"
        echo -e "${Y}Antes:${X} inputguid = controller.guid (automático)"
        echo -e "${Y}Depois:${X} inputguid = \"$controller_guid\" (seu controle)"
        echo
        echo -e "${B}GUID do controle:${X}"
        echo -e "${G}$controller_guid${X}"
        echo
        echo -e "${Y}O gerador Yuzu agora usará este controle por padrão.${X}"
        echo -e "${Y}Execute seus jogos normalmente pelo EmulationStation.${X}"
        echo
        echo -e "${B}Backup salvo em:${X} ${Y}$backup_file${X}"
        echo -e "${B}(Você pode restaurar manualmente se necessário)${X}"
        echo
    else
        echo -e "${R}❌ ERRO AO APLICAR O PATCH!${X}"
        echo -e "${Y}Tentativa manual:${X}"
        echo -e "1. Abra o arquivo: $YUZU_GENERATOR"
        echo -e "2. Procure por: 'inputguid = controller.guid'"
        echo -e "3. Substitua por: 'inputguid = \"$controller_guid\"'"
        echo -e "4. Salve o arquivo"
        echo
        # Restaurar backup em caso de erro
        mv "$backup_file" "$YUZU_GENERATOR"
        echo -e "${Y}Backup restaurado devido ao erro.${X}"
        exit 1
    fi
    
    echo -e "${R}---------------------------------------------------${X}"
    echo -e "${G}✓ Processo concluído com sucesso!${X}"
    echo -e "${R}---------------------------------------------------${X}"
}

# Executar função principal
main "$@"