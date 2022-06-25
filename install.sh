#!/bin/bash
set -e

# The install.sh script is the installation entrypoint for any dev container 'features' in this repository.
#
# The tooling will parse the devcontainer-features.json + user devcontainer, and write
# any build-time arguments into a feature-set scoped "devcontainer-features.env"
# The author is free to source that file and use it however they would like.
set -a
. ./devcontainer-features.env
set +a

if [[ -n ${_BUILD_ARG_OH_MY_POSH} ]]; then
    echo "Activating feature 'oh-my-posh'"

    themeURL=${_BUILD_ARG_OH_MY_POSH_THEMEFILE:-'https://raw.githubusercontent.com/Ash258/Shovel-Ash258/main/support/oh-my-posh/Ash258.yml'}
    themeName=${themeURL##*/}
    themePath="/var/OHM-${themeName}"
    arch=$(uname -m)
    if [[ $arch == 'x86_64' ]]; then
        arch='amd64'
    elif [[ $arch == 'aarch64' ]]; then
        arch='arm64'
    fi

    # Download
    url="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-${arch}"
    wget -O /var/oh-my-posh "$url"
    wget -O "${themePath}" "${themeURL}"

    sudo ln -sf /var/oh-my-posh /usr/local/bin/oh-my-posh

    # Create .zshrc
    cat  <<EOF >> ~/.zshrc
export __SHELL_INFORMATION_POSH_258__="zsh@\$ZSH_VERSION@$arch"
eval "\$(oh-my-posh prompt init zsh --print --config '${themePath}')"
enable_poshtransientprompt
#endregion Oh-my-posh
EOF
    sudo chmod +x /usr/local/bin/oh-my-posh
fi

if [[ -n ${_BUILD_ARG_SHOVEL} ]]; then
    echo "Activating feature 'shovel'"

    defBranch=${_BUILD_ARG_SHOVEL_BRANCH:-'NEW'}
    supportURL='https://raw.githubusercontent.com/shovel-org/Dockers/main/support'

    mkdir -p ~/.config/scoop /opt/Shovel/{apps,shims} ~/Shovel/{apps,shims,buckets,cache}

    git clone --branch "$defBranch" https://github.com/Ash258/Scoop-Core.git ~/Shovel/apps/scoop/current/
    wget -O- "${supportURL}/config.json" | sed 's/main/NEW/g' > ~/.config/scoop/config.json

    wget -O "${HOME}/Shovel/shims/shovel" "${supportURL}/shovel"
    for ext in $(echo ps1 cmd); do
        wget -O "${HOME}/Shovel/shims/shovel.${ext}" "${supportURL}/shovel.${ext}"
    done

    sudo chmod +x ~/Shovel/apps/shims/*

    cat <<EOF >> /etc/profile.d/01-shovel.sh
export SCOOP=~/Shovel
export SCOOP_HOME=~/Shovel/apps/scoop/current
export SCOOP_GLOBAL=/opt/Shovel
export PATH="\$PATH:/opt/Shovel/shims:~/Shovel/shims"
EOF

    which pwsh 2>/dev/null || echo 'To proper functionality powershell feature needs to be enabled'
fi
