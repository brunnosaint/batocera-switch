#!/usr/bin/env bash 
# Patch de controle para Yuzu no Batocera-Switch 
#############################################
clear 

G='\033[1;32m'
R='\033[1;31m'
X='\033[0m'


echo -e "${R}---------${R}--------------------------------------------------"
echo -e "${R}PATCH DE CONTROLE DO YUZU PARA BATOCERA-SWITCH:"
echo -e "${X}/userdata/system/switch/extra/yuzu-controller-patcher.sh"
echo -e "${R}---------${R}--------------------------------------------------"
echo -e "${R}COMO USAR: ${X}" 
echo -e "${X}1  ${R}\ ${X}  ABRA O YUZU EM [F1 → APPS]"
echo -e "${X}2  ${R}/ ${X}  SELECIONE SEU CONTROLE NA SEÇÃO DE DISPOSITIVOS DE ENTRADA"
echo -e "${X}3  ${R}\ ${X}  APLIQUE / SALVE AS CONFIGURAÇÕES"
echo -e "${X}4   ${R}>>${X}  ${X}EXECUTE ESTE SCRIPT" 
echo -e "${R}---------${R}--------------------------------------------------"
echo
echo
echo
# ID correto: 030000005e0400008e02000010010000
# ID automático: 030081b85e0400008e02000010010000

# Extrai o GUID do controle configurado no Yuzu
id="$(cat /userdata/system/configs/yuzu/qt-config.ini | grep 'guid:' | head -n1 | sed 's,^.*guid:,,g' | cut -d "," -f1)"

# Se não encontrar um ID válido, orienta o usuário
if [[ "$id" = "" ]] || [[ "$id" = "0" ]]; then 
	echo -e "${R} NÃO FOI POSSÍVEL ENCONTRAR O ID DO CONTROLE. VOCÊ PRECISA PRIMEIRO CONFIGURAR"
	echo -e "${R} O CONTROLE EM F1 → APPS → YUZU"
	echo 
	echo -e "${R} SELECIONE SEU CONTROLE NA SEÇÃO DE DISPOSITIVOS DE ENTRADA E SALVE"
	echo
	echo -e "${R} DEPOIS, EXECUTE ESTE SCRIPT NOVAMENTE"
	echo
	echo
	exit 0
fi

# Se encontrou um ID válido, prossegue com o patch
if [[ "$id" != "" ]] && [[ "$id" != "0" ]]; then

	id=""$(echo $id)""
	
	# Linha atual no generator do Yuzu
	genline=$(cat /userdata/system/switch/configgen/generators/yuzu/yuzuMainlineGenerator.py | grep 'inputguid = controller.guid')
	replace="$genline"
	replaced=$(echo "$genline" | sed 's,^.*= ,,g')
	# Valor antigo da linha
	old=$(cat /userdata/system/switch/configgen/generators/yuzu/yuzuMainlineGenerator.py | grep 'inputguid = "' | head -n1 | sed 's,^.* = ,,g')
	# Novo valor que será inserido
	new=\"$id\"
	with="                inputguid = \"$id\""
    line="                inputguid = controller.guid"

	# Se já está com o ID correto, informa que já está patchado
	if [[ "$old" = "$new" ]]; then 
		echo -e "${G}---------${G}--------------------------------------------------"
		echo -e "${X}PRONTO! O GERADOR DO YUZU JÁ ESTÁ PATCHADO PARA USAR ESTE CONTROLE"
		echo -e "${G}"$id""
		echo -e "${G}---------${G}--------------------------------------------------"
		echo
		echo -e "${X} "
		echo
		exit 0
	fi

	# Se ainda não está com o ID correto, faz a substituição
	if [[ "$replace" != "$with" ]]; then 

		sed -i "s/^.*inputguid = controller.guid/                inputguid = \"$id\"/g" /userdata/system/switch/configgen/generators/yuzu/yuzuMainlineGenerator.py

		echo -e "${X}---------${X}--------------------------------------------------"
		echo -e "${X}---------${X}--------------------------------------------------"
		echo
		echo -e "${G}PRONTO! O GERADOR DO YUZU FOI PATCHADO ${X}"
		echo 
		echo -e "${X}SUBSTITUÍDO ${X}"
		echo -e "inputguid = $replaced"
		echo
		echo -e "${X}POR ${X}"
		echo -e "inputguid = \"$id\""
		echo
		echo -e "${X}---------${X}--------------------------------------------------"
		echo -e "${X}---------${X}--------------------------------------------------"
		echo
		echo -e "${X} "
		echo
		exit 0
	fi

fi