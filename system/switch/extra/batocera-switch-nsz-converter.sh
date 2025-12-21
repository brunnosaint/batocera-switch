#!/bin/bash
# Conversor NSZ/XCZ para Batocera Switch
#########################################################################################################################

#-------------------------------------------
# Obter nome do arquivo da ROM
	rom="$(cat /tmp/switchromname)"
#-------------------------------------------
# Configurar comando 'rev' (reverter string)
	cp /userdata/system/switch/extra/batocera-switch-rev /usr/bin/rev 2>/dev/null 
	chmod a+x /usr/bin/rev 2>/dev/null 
#-------------------------------------------

# ===========================================
# PROCESSAR ARQUIVOS .NSZ
# ===========================================
# Verificar se a ROM termina com .nsz
if [[ "$(echo "$rom" | rev | cut -c 1-4 | rev)" = ".nsz" ]]; then 
	echo "Arquivo NSZ detectado!"
	
	# ------------------------------------------------------ 
	# Verificar se o conversor NSZ está disponível
	# Se não estiver instalado, instalar
	if [[ "$(which nsz | head -n 1 | grep "not found")" != "" ]] || [[ "$(which nsz | head -n 1)" = "" ]]; then 
		function nsz-install() 
		{
			echo -e "╔═════════════════════════════════════════════╗ "
			echo -e "║ PREPARANDO CONVERSOR NSZ & XCZ . . .        ║ "
			echo -e "╚═════════════════════════════════════════════╝ "
			echo
			echo
			# Instalar dependências Python
			python -m ensurepip --default-pip 1>/dev/null 2>/dev/null 
			python -m pip install --upgrade pip 1>/dev/null 2>/dev/null 
			python -m pip install --upgrade --force-reinstall pycryptodome 1>/dev/null 2>/dev/null 
			python -m pip install --upgrade --force-reinstall nsz 1>/dev/null 2>/dev/null 
			wait
			sleep 0.1
		}
		export -f nsz-install
		
		# Executar o instalador em terminal gráfico
		cp /usr/bin/xterm /usr/bin/nszinstall 2>/dev/null
		chmod a+x /usr/bin/nszinstall
		DISPLAY=:0.0 /usr/bin/nszinstall -fs 8 -fullscreen -fg black -bg gray -fa Monospace -en UTF-8 -e bash -c "nsz-install" 2>/dev/null 
		wait
		killall -9 nszinstall && rm /usr/bin/nszinstall 2>/dev/null
	fi
	# ------------------------------------------------------ 
	
	# Função para converter NSZ para NSP
	function convert-nsz() 
	{
		echo -e "╔═════════════════════════════════════════════╗ "
		echo -e "║ CONVERTENDO NSZ PARA NSP . . .              ║ "
		echo -e "╚═════════════════════════════════════════════╝ "
		echo
		echo
		
		#-------------------------------------------
		# Obter ROM do arquivo temporário
		rom="$(cat /tmp/switchromname)"
		#-------------------------------------------
		
		# Configurar dependências das bibliotecas
		chmod a+x /userdata/system/switch/extra/nsz/lib-dynload/*.so 2>/dev/null
		
		# Para Python 3.11
		if [[ -d "/usr/lib/python3.11" ]]; then 
			cp -r /userdata/system/switch/extra/nsz/curses /usr/lib/python3.11/site-packages/ 2>/dev/null
			cp /userdata/system/switch/extra/nsz/lib-dynload/_curses.cpython-310-x86_64-linux-gnu.so /usr/lib/python3.11/lib-dynload/_curses.cpython-311-x86_64-linux-gnu.so
			cp /userdata/system/switch/extra/nsz/lib-dynload/_curses_panel.cpython-310-x86_64-linux-gnu.so /usr/lib/python3.11/lib-dynload/_curses_panel.cpython-311-x86_64-linux-gnu.so
		fi
		
		# Para Python 3.10
		if [[ -d "/usr/lib/python3.10" ]]; then 
			cp -r /userdata/system/switch/extra/nsz/curses /usr/lib/python3.10/site-packages/ 2>/dev/null
			cp /userdata/system/switch/extra/nsz/lib-dynload/_curses.cpython-310-x86_64-linux-gnu.so /usr/lib/python3.10/lib-dynload/_curses.cpython-310-x86_64-linux-gnu.so
			cp /userdata/system/switch/extra/nsz/lib-dynload/_curses_panel.cpython-310-x86_64-linux-gnu.so /usr/lib/python3.10/lib-dynload/_curses_panel.cpython-310-x86_64-linux-gnu.so
		fi
		#-------------------------------------------
		
		# Copiar chaves de produto para local padrão
		cp /userdata/bios/switch/prod.keys /usr/bin/keys.txt 2>/dev/null
		#-------------------------------------------
		
		# Executar conversão
		sleep 0.5 && nsz -D -w -t 4 -P "$rom" 
		wait
		
		echo -e "╔═════════════════════════════════════════════╗ "
		echo -e "║ CONVERSÃO PARA NSP CONCLUÍDA                ║ "
		echo -e "╚═════════════════════════════════════════════╝ "
		sleep 0.5 					
		#-------------------------------------------
		
		# Opcional: remover arquivo NSZ original
		# rm -rf "$rom" 2>/dev/null
		
		# Recarregar lista de jogos no EmulationStation
		curl http://127.0.0.1:1234/reloadgames 
	} 
	
	export -f convert-nsz
	#-------------------------------------------
	
	# Executar conversão em terminal gráfico
	cp /usr/bin/xterm /usr/bin/nszconvert 2>/dev/null
	chmod a+x /usr/bin/nszconvert 
	DISPLAY=:0.0 /usr/bin/nszconvert -fs 8 -fullscreen -fg black -bg gray -fa Monospace -en UTF-8 -e bash -c "clear && convert-nsz && sleep 1 && clear" 2>/dev/null 
	wait
	killall -9 nszconvert && rm /usr/bin/nszconvert 2>/dev/null
	#-------------------------------------------
	
	# Atualizar cookie da ROM para o launcher/emulador
	rompath="$(dirname "$rom")"
	romname="$(basename "$rom" ".nsz")"
	rom="$rompath/$romname.nsp"
	
	rm /tmp/switchromname 2>/dev/null
	echo "$rom" >> /tmp/switchromname 
	# ==================================================
fi 

# ===========================================
# PROCESSAR ARQUIVOS .XCZ
# ===========================================
# Verificar se a ROM termina com .xcz
if [[ "$(echo "$rom" | rev | cut -c 1-4 | rev)" = ".xcz" ]]; then 
	echo "Arquivo XCZ detectado!"
	
	# ------------------------------------------------------ 
	# Verificar se o conversor NSZ está disponível
	# Se não estiver instalado, instalar
	if [[ "$(which nsz | head -n 1 | grep "not found")" != "" ]] || [[ "$(which nsz | head -n 1)" = "" ]]; then 
		function nsz-install() 
		{
			echo -e "╔═════════════════════════════════════════════╗ "
			echo -e "║ PREPARANDO CONVERSOR NSZ & XCZ . . .        ║ "
			echo -e "╚═════════════════════════════════════════════╝ "
			echo
			echo
			# Instalar dependências Python
			python -m ensurepip --default-pip 1>/dev/null 2>/dev/null 
			python -m pip install --upgrade pip 1>/dev/null 2>/dev/null 
			python -m pip install --upgrade --force-reinstall pycryptodome 1>/dev/null 2>/dev/null 
			python -m pip install --upgrade --force-reinstall nsz 1>/dev/null 2>/dev/null 
			wait
			sleep 0.1
		}
		export -f nsz-install
		
		# Executar o instalador em terminal gráfico
		cp /usr/bin/xterm /usr/bin/nszinstall 2>/dev/null
		chmod a+x /usr/bin/nszinstall
		DISPLAY=:0.0 /usr/bin/nszinstall -fs 8 -fullscreen -fg black -bg gray -fa Monospace -en UTF-8 -e bash -c "nsz-install" 2>/dev/null 
		wait
		killall -9 nszinstall && rm /usr/bin/nszinstall 2>/dev/null
	fi
	# ------------------------------------------------------ 
	
	# Função para converter XCZ para XCI
	function convert-xcz() 
	{
		echo -e "╔═════════════════════════════════════════════╗ "
		echo -e "║ CONVERTENDO XCZ PARA XCI . . .              ║ "
		echo -e "╚═════════════════════════════════════════════╝ "
		echo
		echo
		
		#-------------------------------------------
		# Obter ROM do arquivo temporário
		rom="$(cat /tmp/switchromname)"
		#-------------------------------------------
		
		# Configurar dependências das bibliotecas
		chmod a+x /userdata/system/switch/extra/nsz/lib-dynload/*.so 2>/dev/null
		
		# Para Python 3.11
		if [[ -d "/usr/lib/python3.11" ]]; then 
			cp -r /userdata/system/switch/extra/nsz/curses /usr/lib/python3.11/site-packages/ 2>/dev/null
			cp /userdata/system/switch/extra/nsz/lib-dynload/_curses.cpython-310-x86_64-linux-gnu.so /usr/lib/python3.11/lib-dynload/_curses.cpython-311-x86_64-linux-gnu.so
			cp /userdata/system/switch/extra/nsz/lib-dynload/_curses_panel.cpython-310-x86_64-linux-gnu.so /usr/lib/python3.11/lib-dynload/_curses_panel.cpython-311-x86_64-linux-gnu.so
		fi
		
		# Para Python 3.10
		if [[ -d "/usr/lib/python3.10" ]]; then 
			cp -r /userdata/system/switch/extra/nsz/curses /usr/lib/python3.10/site-packages/ 2>/dev/null
			cp /userdata/system/switch/extra/nsz/lib-dynload/_curses.cpython-310-x86_64-linux-gnu.so /usr/lib/python3.10/lib-dynload/_curses.cpython-310-x86_64-linux-gnu.so
			cp /userdata/system/switch/extra/nsz/lib-dynload/_curses_panel.cpython-310-x86_64-linux-gnu.so /usr/lib/python3.10/lib-dynload/_curses_panel.cpython-310-x86_64-linux-gnu.so
		fi
		#-------------------------------------------
		
		# Copiar chaves de produto para local padrão
		cp /userdata/bios/switch/prod.keys /usr/bin/keys.txt 2>/dev/null
		#-------------------------------------------
		
		# Executar conversão
		sleep 0.5 && nsz -D -w -t 4 -P "$rom" 
		wait
		
		echo -e "╔═════════════════════════════════════════════╗ "
		echo -e "║ CONVERSÃO PARA XCI CONCLUÍDA                ║ "
		echo -e "╚═════════════════════════════════════════════╝ "
		sleep 0.5 					
		#-------------------------------------------
		
		# Opcional: remover arquivo XCZ original
		# rm -rf "$rom" 2>/dev/null
		
		# Recarregar lista de jogos no EmulationStation
		curl http://127.0.0.1:1234/reloadgames 
	} 
	
	export -f convert-xcz
	#-------------------------------------------
	
	# Executar conversão em terminal gráfico
	cp /usr/bin/xterm /usr/bin/nszconvert 2>/dev/null
	chmod a+x /usr/bin/nszconvert 
	DISPLAY=:0.0 /usr/bin/nszconvert -fs 8 -fullscreen -fg black -bg gray -fa Monospace -en UTF-8 -e bash -c "clear && convert-xcz && sleep 1 && clear" 2>/dev/null 
	wait
	killall -9 nszconvert && rm /usr/bin/nszconvert 2>/dev/null
	#-------------------------------------------
	
	# Atualizar cookie da ROM para o launcher/emulador
	rompath="$(dirname "$rom")"
	romname="$(basename "$rom" ".xcz")"
	rom="$rompath/$romname.xci"
	
	rm /tmp/switchromname 2>/dev/null
	echo "$rom" >> /tmp/switchromname 
	# ==================================================
fi 

exit 0