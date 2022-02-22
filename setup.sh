#! /usr/bin/sh

echo "Enable multilib repository..."
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

echo "Update packages..."
sudo pacman -Syu

echo "Install initial packages..."
sudo pacman -S \
    base-devel \
    curl \
    wget \
    vim \
    neovim \
    neofetch \
    xclip \
    git \
    openssh \
    kdeconnect

echo "Set up your Git config"
while true; do
    if [ -f $HOME/.gitconfig ]; then
        read -p "Do you want to exclude .gitconfig file? [Y/n]: " answer
        case $answer in
            [Yy]*   ) rm $HOME/.gitconfig; continue;;
            [Nn]*   ) break;;
            *       ) rm $HOME/.gitconfig; continue;;
        esac
    fi

    read -p "Insert your name what you want to use in Git user.name: " git_user_name
    git config --global user.name "$git_user_name"

    read -p "Insert your e-mail what you want to use in Git user.email: " git_user_email
    git config --global user.email $git_user_email

    echo "Generating a SSH key..."
    ssh-keygen -t rsa -b 4096 -C $git_user_email
    ssh-add $HOME/.ssh/id_rsa

    read -p "Can I set NEOVIM as your default Git editor? [Y/n]: " $git_default_editor
    case $git_default_editor in
        [Yy]*   ) git config --global core.editor vim;;
        [Nn]*   ) read -p "What editor do you want to use? " git_user_editor; git config --global core.editor $git_user_editor;;
        *       ) git config --global core.editor vim;;
    esac

    git config --global pull.rebase false
    git config --global credential.helper store
    clear

    echo "Config Git aliases..."
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

echo "Installing fonts..."
sudo pacman -S \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-cjk \
    noto-fonts-extra \
    ttf-fira-code \
    ttf-liberation \
    adobe-source-han-sans-otc-fonts \
    adobe-source-han-serif-otc-fonts
clear

echo "Installing ZSH..."
sudo pacman -S zsh

echo "Installing Oh my ZSH..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "Changing ZSH Theme..."
sed -i 's/.*ZSH_THEME=.*/ZSH_THEME="agnoster"/g' $HOME/.zshrc

echo "Add plugins to ZSH file..."
sed -i 's/.*plugins=()/plugins=(\ngit\nzsh-autosuggestions\nzsh-completion\n)/g' $HOME/.zshrc

echo "Installing ZInit..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

echo "Installing ZInit plugins..."
echo -e "
zinit light zdharma/fast-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light buonomo/yarn-completion" >> $HOME/.zshrc

clear

echo "Installing NVM..."
sh -c "$(curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh)"

source $HOME/.zshrc
clear

echo "Installing Node.js LTS version..."
nvm --version
nvm install --lts
npm --version
node --version
clear

echo "Installing Yarn..."
sudo pacman -S yarn
clear

echo "Installing YAY..."
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd .. && rm -rf yay
clear

echo "Installing Google Chrome..."
yay -S google-chrome
clear

echo "Installing Brave Browser..."
yay -S brave

echo "Installing Visual Studio Code..."
yay -S visual-studio-code-bin

echo "Installing VSCode extensions..."
code --install-extension PKief.material-icon-theme
code --install-extension Equinusocio.vsc-material-theme
code --install-extension GitHub.vscode-pull-request-github
code --install-extension naumovs.color-highlight
code --install-extension ms-azuretools.vscode-docker
code --install-extension EditorConfig.EditorConfig
code --install-extension eamodio.gitlens
code --install-extension jpoissonnier.vscode-styled-components
code --install-extension mhutchie.git-graph
code --install-extension ms-vscode.cpptools
code --install-extension rust-lang.rust
code --install-extension usernamehw.errorlens
code --install-extension christian-kohler.path-intellisense
code --install-extension WakaTime.vscode-wakatime

echo "Installing Spotify..."
yay -S spotify
curl -sS https://download.spotify.com/debian/pubkey.gpg | gpg --import -
clear

echo "Installing Discord..."
sudo pacman -S discord
clear

echo "Installing Docker..."
sudo pacman -S docker
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker
docker --version

echo "Installing Docker-Compose..."
sudo pacman -S docker-compose
docker-compose --version
clear

echo "Installing Slack desktop..."
yay -S slack-desktop
clear

echo "Installing Steam..."
sudo pacman -S steam
clear

echo "Installing Terminator..."
sudo pacman -S terminator
clear

read -p "Do you want to reboot your machine to apply changes? [Y/n]: " answer
case $answer in
    [Ýy]*   ) sudo reboot;;
    [Nn]*   ) zsh; exit;;
    *       ) sudo reboot;;
esac
