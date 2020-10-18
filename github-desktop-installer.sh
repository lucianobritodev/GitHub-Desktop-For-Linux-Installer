#!/usr/bin/env bash
# ----------------------------------------------------------------------------------- #
# github-desktop-installer.sh
#
# E-mail:     lucianobrito.dev@gmail.com
# Autor:      Luciano Brito
# Telefone:   +55 61 996787597
# Manutenção: Luciano Brito
#
#
# ----------------------------------------------------------------------------------- #
#  Descrição: Notifica ao usuario sempre que for lançada uma nova release.
#
#  Exemplos:
#      $ ./github-desktop-installer.sh
#
#      	Neste exemplo será executado o programa que fará a verificação de lançamento
#		de novas versões do software. Uma vez confirmada a versão lançada será sugerido
#		ao usuário a atualização do mesmo via GUI GTK criada através do zenity.
#
#
# ----------------------------------------------------------------------------------- #
# Histórico:
#
#   v1.0 01/05/2020, Luciano
#		- Criado software de monitoramento de novas releases do github-desktop para linux.
#
#
#   v1.1 03/05/2020, Luciano
#		- Atualização do código e comentários.
#		- Atualização do nome do script.
#		- Adicionado função de notificação.
#
#
#   v2.0 05/10/2020, Luciano
#		- Atualização do código e comentários.
#		- Adicionado função de senha.
#		- Adicionado função de instalação de dependências.
#		- Realizado o desacoplamento das funções.
#		- Removido notificação de comparação de versões instaladas e remota.
#
#
#   v3.0 18/10/2020, Luciano
#		- Modificado função de notificação aplicado o conceito de polimorfismo.
#		- Desacoplamento das funções de verificação de instalação.
#		- Adicionado função de verificação da instalação do software no início.
#		- Adicionado duas variáveis, uma global que captura o caminho software
# 			e outra local que captura a versão do software instalado.
#		- Testes feito com zsh 5.4.2.
#		- Adicionado comentários de versionamento do software.
#		- Adicionado função de verificação de internet.
#
# ----------------------------------------------------------------------------------- #
# Testado em:
#   bash 4.4.19
#	bash 4.4.20(1)
#	zsh 5.4.2
#
#
# -------------------------------- VARIABLE ----------------------------------------- #
PASSWORD=
CHECK_GITHUB_DESKTOP_INSTALLED=$(which github-desktop)
GITHUB_DESKTOP_INFORMATION=/home/$USER/.github-desktop/github-desktop-information.txt
INSTALLED_VERSION=/home/$USER/.github-desktop/github-desktop-version.txt
UPDATED_VERSION=
RELEASE=
LINK=
SEP="|"


# -------------------------------- TESTS ------------------------------------------- #


#-------------------------------- FUNCTIONS --------------------------------------------#

function test-conection {
	$(ping -c 2 www.github.com 1>&/dev/null)
	if [ $? != 0 ]; then 
		$(ping -c 2 www.google.com 1>&/dev/null)
		if [ $? != 0 ]; then
			zenity --notification --text="GitHub-Desktop\nNão foi possível verificar outra versão do GitHub-Desktop! Por favor, verifique sua conexão com a internet."
			exit 1
		fi
	fi
}

function password() {
	PASSWORD="$(zenity --password)"
}

function install-github-desktop() {
	password
	dependences
	rm -Rf github-desktop.deb*
	xterm -e "wget -c $LINK -O github-desktop.deb"
	echo "$PASSWORD" | sudo -S xterm -e "gdebi -n github-desktop.deb"
	echo "$UPDATED_VERSION" > $INSTALLED_VERSION
}

function notification() {

	zenity --notification --text="GitHub-Desktop\nGitHub-Desktop $1 $2!"
}

function dependences() {
	[ ! -x $(which lynx) ]	 && echo "$PASSWORD" | sudo -S apt install lynx   -y 	# Is Lynx	Installed?
	[ ! -x $(which gdebi) ]  && echo "$PASSWORD" | sudo -S apt install gdebi  -y 	# Is Gdebi	Installed?
	[ ! -x $(which zenity) ] && echo "$PASSWORD" | sudo -S apt install zenity -y 	# Is Zenity	Installed?	
}

# -------------------------------- EXECUTION ----------------------------------------- #
clear

test-conection

[ ! -d /home/$USER/.github-desktop/ ] && mkdir /home/$USER/.github-desktop/
cd /home/$USER/.github-desktop/
lynx --source https://github.com/shiftkey/desktop/releases |\
 grep -A 1 '<a href="/shiftkey/desktop/releases/tag/release-' |\
  head -1 | sed "s/<a\ href=\"//;s/<\/a>//;s/\">/|/" > $GITHUB_DESKTOP_INFORMATION

RELEASE=$(cat $GITHUB_DESKTOP_INFORMATION | cut -d "$SEP" -f 1 | sed "s/\/shiftkey\/desktop\/releases\/tag\/release-//;s/ //g")
UPDATED_VERSION="$(cat $GITHUB_DESKTOP_INFORMATION  | cut -d $SEP -f 2)"
LINK="https://github.com/shiftkey/desktop/releases/download/release-$RELEASE/GitHubDesktop-linux-$RELEASE.deb"

#  Is github-desktop Installed?
if ! [ -e "$CHECK_GITHUB_DESKTOP_INSTALLED" ]; then
	zenity --question --title="Instalação do GitHub-Desktop" --text="O GitHub-Desktop não está instalado, você deseja instalá-lo agora?\n\n" --ellipsize
	[ $? == 0 ] && install-github-desktop
	echo "$UPDATED_VERSION" > $INSTALLED_VERSION
	VERSION="$(cat $INSTALLED_VERSION)"
	notification "foi instalado com sucesso e está na versão" "$VERSION"
	exit 0
fi

# Is github-desktop Updated?
if [ "$(cat $INSTALLED_VERSION)" != "$(echo $UPDATED_VERSION)" ]; then
	zenity --question --title="Atualização do GitHub-Desktop" --text="Existe uma nova versão do GitHub-Desktop disponível!\nVocê deseja atualizá-lo agora?\n\n" --ellipsize
	[ $? == 0 ] && install-github-desktop
	echo "$UPDATED_VERSION" > $INSTALLED_VERSION
	VERSION="$(cat $INSTALLED_VERSION)"
	notification "foi atualizado com sucesso e está na versão" "$VERSION"
else
	VERSION="$(cat $INSTALLED_VERSION)"
	notification "já está instalado na ultima versão disponível" "$VERSION"
fi

exit 0