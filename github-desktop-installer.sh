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
#		- Criado software de monitoramento de novas releases do github-desktop para linux
#
#
#   v1.1 03/05/2020, Luciano
#		- Atualização do código e comentários
#		- Atualização do nome do script
#		- Adicionado função de notificação
#
#
#   v2.0 05/10/2020, Luciano
#		- Atualização do código e comentários
#		- Adicionado função de senha, dependências e desacoplamento.
#
# ----------------------------------------------------------------------------------- #
# Testado em:
#   bash 4.4.19
#	bash 4.4.20(1)
#
#
# -------------------------------- VARIABLE ----------------------------------------- #
PASSWORD=
GITHUB_DESKTOP_INFORMATION=/home/$USER/.github-desktop/github-desktop-information.txt
INSTALLED_VERSION="/home/$USER/.github-desktop/github-desktop-version.txt"
UPDATED_VERSION=
RELEASE=
LINK=
SEP="|"
# -------------------------------- TESTS ------------------------------------------- #


#-------------------------------- FUNCTIONS --------------------------------------------#
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

	zenity --notification --text="GitHub-Desktop\nGitHub-Desktop está instalado na versão $1."
}

function dependences() {
	[ ! -x $(which lynx) ]	 && echo "$PASSWORD" | sudo -S apt install lynx   -y 	# Is Lynx	Installed?
	[ ! -x $(which gdebi) ]  && echo "$PASSWORD" | sudo -S apt install gdebi  -y 	# Is Gdebi	Installed?
	[ ! -x $(which zenity) ] && echo "$PASSWORD" | sudo -S apt install zenity -y 	# Is Zenity	Installed?	
}

# -------------------------------- EXECUTION ----------------------------------------- #
clear

[ ! -d /home/$USER/.github-desktop/ ] && mkdir /home/$USER/.github-desktop/
cd /home/$USER/.github-desktop/
lynx --source https://github.com/shiftkey/desktop/releases |\
 grep -A 1 '<a href="/shiftkey/desktop/releases/tag/release-' |\
  head -1 | sed "s/<a\ href=\"//;s/<\/a>//;s/\">/|/" > /home/$USER/.github-desktop/github-desktop-information.txt

RELEASE=$(cat $GITHUB_DESKTOP_INFORMATION | cut -d "$SEP" -f 1 | sed "s/\/shiftkey\/desktop\/releases\/tag\/release-//;s/ //g")
UPDATED_VERSION=$(cat $GITHUB_DESKTOP_INFORMATION  | cut -d "$SEP" -f 2)
LINK="https://github.com/shiftkey/desktop/releases/download/release-$RELEASE/GitHubDesktop-linux-$RELEASE.deb"

#  Is github-desktop Installed?
if [ -e $(which github-desktop) != 0 ]; then
	zenity --question --title="Instalação do GitHub-Desktop" --text="O GitHub-Desktop não esta instalado, você deseja instalá-lo agora?\n\n" --ellipsize
	[ $? == 0 ] && install-github-desktop
	unset INSTALLED_VERSION && INSTALLED_VERSION="$UPDATED_VERSION"
	notification "$INSTALLED_VERSION"
	exit 0
fi

# Is github-desktop Updated?
if [ "$(cat $INSTALLED_VERSION)" != "$(echo $UPDATED_VERSION)" ]; then
	zenity zenity --question --title="Atualização do GitHub-Desktop" --text="Existe uma nova versão do GitHub-Desktop, você deseja atualizá-lo agora?\n\n" --ellipsize
	[ $? == 0 ] && install-github-desktop
	unset INSTALLED_VERSION && INSTALLED_VERSION="$UPDATED_VERSION"
	notification "$INSTALLED_VERSION"
else
	zenity  --warning --text="A versão do GitHub-Desktop disponível no repositório remoto é a mesma instalada!\n\n" --ellipsize
	INSTALLED_VERSION="$(cat $INSTALLED_VERSION)"
	notification "$INSTALLED_VERSION"
fi

exit 0