#!/usr/bin/env bash
# ----------------------------------------------------------------------------------- #
# github-desktop-notifier.sh
#
# E-mail:     lucianobrito.dev@gmail.com
# Autor:      Luciano Brito
# Telefone:   +55 61 996787597
# Manutenção: Luciano Brito
#
# ----------------------------------------------------------------------------------- #
#  Descrição: Notifica ao usuario sempre que for lançada uma nova release.
#
#  Exemplos:
#      $ ./github-desktop-notifier.sh
#
#      	Neste exemplo será executado o programa que fará a verificação de lançamento
#		de novas versões do software. Uma vez confirmada a versão lançada será sugerido
#		ao usuário a atualização do mesmo via GUI GTK criada através do zenity.
# ----------------------------------------------------------------------------------- #
# Histórico:
#
#   v1.0 01/05/2020, Luciano
#		- Criado software de monitoramento de novas releases do github-desktop para linux
#
# ----------------------------------------------------------------------------------- #
# Testado em:
#   bash 4.4.19
#
# ------------------------------- VARIÁVEIS ----------------------------------------- #
PASSWORD="$(zenity --password)"
GITHUB_DESKTOP_INFORMATION=/home/$USER/.github-desktop/github-desktop-information.txt
INSTALLED_VERSION="/home/$USER/.github-desktop/github-desktop-version.txt"
UPDATED_VERSION=
RELEASE=
LINK=
SEP="|"
# ------------------------------- TESTES -------------------------------------------- #
[ ! -x $(which lynx) ]	 && sudo apt install lynx   -y 	# Lynx 	 Instalado?
[ ! -x $(which gdebi) ]  && sudo apt install gdebi  -y 	# Gdebi Instalado?
[ ! -x $(which zenity) ] && sudo apt install zenity -y 	# Zenity Instalado?

#-------------------------------- FUNÇÕES --------------------------------------------#
function install-github-desktop() {
	rm -Rf github-desktop.deb*
	xterm -e "wget -c $LINK -O github-desktop.deb"
	echo "$PASSWORD" | sudo -S xterm -e "gdebi -n github-desktop.deb"
	echo "$UPDATED_VERSION" > $INSTALLED_VERSION
}

# ------------------------------- EXECUÇÃO ------------------------------------------ #
clear
[ ! -d /home/$USER/.github-desktop/ ] && mkdir /home/$USER/.github-desktop/
cd /home/$USER/.github-desktop/
lynx --source https://github.com/shiftkey/desktop/releases |\
 grep -A 1 '<a href="/shiftkey/desktop/releases/tag/release-' |\
  head -1 | sed "s/<a\ href=\"//;s/<\/a>//;s/\">/|/" > /home/$USER/.github-desktop/github-desktop-information.txt

RELEASE=$(cat $GITHUB_DESKTOP_INFORMATION | cut -d "$SEP" -f 1 | sed "s/\/shiftkey\/desktop\/releases\/tag\/release-//;s/ //g")
UPDATED_VERSION=$(cat $GITHUB_DESKTOP_INFORMATION  | cut -d "$SEP" -f 2)
LINK="https://github.com/shiftkey/desktop/releases/download/release-$RELEASE/GitHubDesktop-linux-$RELEASE.deb"

#  github-desktop Instalado?
if [ -e $(which github-desktop) != 0 ]; then
	zenity --question --title="Instalação do GitHub-Desktop" --text="O GitHub-Desktop não esta instalado, você deseja instalá-lo agora?\n\n" --ellipsize
	[ $? == 0 ] && install-github-desktop
	exit 0
fi

# github-desktop atualizado?
if [ "$(cat $INSTALLED_VERSION)" != "$(echo $UPDATED_VERSION)" ]; then
	zenity zenity --question --title="Atualização do GitHub-Desktop" --text="Existe uma nova versão do GitHub-Desktop, você deseja atualizá-lo agora?\n\n" --ellipsize
	[ $? == 0 ] && install-github-desktop
else
	zenity  --warning --text="A versão do GitHub-Desktop disponível no repositório remoto é a mesma instalada!\n\n" --ellipsize
fi

exit 0