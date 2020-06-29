#! /usr/bin/bash

#########################################################
#                       HELPERS                         #
#########################################################

get_value_of()
{
    local VAR_NAME=$1;
    local VAR_VALUE="";

    if set | grep -q "^$VAR_NAME="; then
        eval VAR_VALUE="\$$VAR_NAME"
    fi
    echo "$VAR_VALUE"
}

display_color_text()
{
    local RED=`tput setaf 1`;
    local GREEN=`tput setaf 2`;
    local YELLOW=`tput setaf 3`;
    local BLUE=`tput setaf 4`;

    local RESET_TEXT=`tput sgr0`;

    echo "$(get_value_of $1)$2$RESET_TEXT"
}

#########################################################
#                       CODE                            #
#########################################################

display_color_text GREEN "Sync Arch Deps Database"
sudo pacman -Syu
clear

display_color_text GREEN "Install Initial Deps"
sudo pacman -S base-devel curl wget vim neovim neofetch xclip
clear


display_color_text GREEN "Installing Git dependency..."
sudo pacman -S git
clear

display_color_text GREEN "Set up your Git config"
while true; do
    if [ -f $HOME/.gitconfig ]; then
        read -p "$(display_color_text RED 'Do you want to exclude .gitconfig file? [Y/n]: ')" answer
        case $answer in
           [Yy]*   ) rm -rf $HOME/.gitconfig; continue;;
           [Nn]*   ) break;;
           *       ) rm -rf $HOME/.gitconfig; continue;;
        esac
    fi

    read -p "$(display_color_text YELLOW 'Insert your name what you want to use in Git user.name: ')" GIT_NAME
    git config --global user.name "$GIT_NAME"

    read -p "$(display_color_text YELLOW 'Insert your e-mail what you want to use in Git user.email: ')" GIT_EMAIL
    git config --global user.email $GIT_EMAIL

    display_color_text GREEN "Generating a SSH Key..."
    ssh-keygen -t rsa -b 4096 -C $GIT_EMAIL
    ssh-add $HOME/.ssh/id_rsa

    read -p "$(display_color_text YELLOW 'Can I set VIM as your default GIT editor for you? [Y/n]: ')" GIT_DEFAULT_EDITOR
    case $GIT_DEFAULT_EDITOR in
        [Yy]*   ) git config --global core.editor vim;;
        [Nn]*   ) read -p "What editor do you want to use? " EDITOR; git config --global core.editor $EDITOR;;
        *       ) git config --global core.editor vim;;
    esac

    git config --global pull.rebase false
    git config --global credential.helper store
    clear

    display_color_text GREEN "Config Git aliases...";
    git config --global alias.pom "push origin master -u"
    git config --global alias.ci "commit"
    git config --global alias.co "checkout"
    git config --global alias.cm "checkout master"
    git config --global alias.cb "checkout -b"
    git config --global alias.st "status -sb"
    git config --global alias.sf "show --name-only"
    git config --global alias.lg "log --pretty=format:'%Cred%h%Creset %C(bold)%cr%Creset %Cgreen<%an>%Creset %s' --max-count=30"
    git config --global alias.incoming "!(git fetch --quiet && git log --pretty=format:'%C(yellow)%h %C(white)- %C(red)%an %C(white)- %C(cyan)%d%Creset %s %C(white)- %ar%Creset' ..@{u})"
    git config --global alias.outgoing "!(git fetch --quiet && git log --pretty=format:'%C(yellow)%h %C(white)- %C(red)%an %C(white)- %C(cyan)%d%Creset %s %C(white)- %ar%Creset' @{u}..)"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.undo "checkout --"
    git config --global alias.rollback "reset --soft HEAD~1"

    break;
done

display_color_text GREEN "Installing Fonts..."
sudo pacman -S \
   noto-fonts-emoji \
   noto-fonts \
   noto-fonts-cjk \
   noto-fonts-extra \
   ttf-firacode \
   adobe-source-han-sans-otc-fonts \
   adobe-source-han-serif-otc-fonts 
clear


display_color_text GREEN "Installing ZSH..."
sudo pacman -S zsh

display_color_text GREEN "Installing Oh my ZSH..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s /bin/zsh

display_color_text GREEN "Changing ZSH Theme..."
sed -i 's/.*ZSH_THEME=.*/ZSH_THEME="agnoster"/g' $HOME/.zshrc
source $HOME/.zshrc
clear

display_color_text GREEN "Installing ZInit..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

display_color_text GREEN "Installing ZInit Plugins..."
echo -e "
zinit light zdharma/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
zinit light zsh-users/zsh-completions
zinit light buonomo/yarn-completion" >> $HOME/.zshrc
clear

display_color_text GREEN "Installing NVM..."
sh -c "$(curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh)"

export NVM_DIR="$HOME/.nvm" && (
git clone https://github.com/creationix/nvm.git "$NVM_DIR"
cd "$NVM_DIR"
git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

clear

source $HOME/.zshrc
display_color_text GREEN "Installing Node.js LTS version..."
nvm --version
nvm install --lts
npm --version
node --version
clear

source $HOME/.zshrc
display_color_text GREEN "Installing Yarn..."
npm install -g yarn
clear

display_color_text GREEN "Installing BuckleScript..."
npm install -g bs-platform
clear

display_color_text GREEN "Installing Yay..."
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd .. && rm -rf yay
clear

display_color_text GREEN "Installing Google Chrome..."
yay -S google-chrome
clear

display_color_text GREEN "Installing Visual Studio Code..."
yay -S visual-studio-code-bin
clear

display_color_text GREEN "Install Visual Studio Code Extensions..."
code --install-extension naumovs.color-highlight
code --install-extension ms-azuretools.vscode-docker
code --install-extension EditorConfig.EditorConfig
code --install-extension PKief.material-icon-theme
code --install-extension WakaTime.vscode-wakatime
code --install-extension freebroccolo.reasonml
code --install-extension jaredly.reason-vscode
code --install-extension eamodio.gitlens
code --install-extension jpoissonnier.vscode-styled-components
code --install-extension mhutchie.git-graph
code --install-extension christian-kohler.path-intellisense
clear

display_color_text GREEN "Installing Spotify..."
yay -S spotify
curl -sS https://download.spotify.com/debian/pubkey.gpg | gpg --import -
clear

display_color_text GREEN "Installing Discord..."
sudo pacman -S discord
clear

display_color_text GREEN "Installing Docker..."
sudo pacman -S docker
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker
docker --version
clear

display_color_text GREEN "Installing Docker-Compose..."
sudo pacman -S docker-compose
docker-compose --version
clear

while true; do
    read -p "$(display_color_text RED 'Do you want to reboot your machine to apply changings? [Y/n]: ')" answer
    case $answer in
        [Yy]*   ) sudo reboot;;
        [Nn]*   ) zsh; exit;;
        *       ) sudo reboot;;
    esac
done
