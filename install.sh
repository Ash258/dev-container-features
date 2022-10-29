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

    themeURL=${_BUILD_ARG_OH_MY_POSH_THEMEFILE:-https://raw.githubusercontent.com/Ash258/Shovel-Ash258/main/support/oh-my-posh/Ash258.yml}
    themeName=${themeURL##*/}
    themePath="/var/OMP-${themeName}"
    arch=$(uname -m)
    if [[ $arch == 'x86_64' ]]; then
        arch='amd64'
    elif [[ $arch == 'aarch64' ]]; then
        arch='arm64'
    fi

    # Download
    url="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-${arch}"
    wget -O '/var/oh-my-posh' "${url}"
    wget -O "${themePath}" "${themeURL}"

    sudo ln -sf '/var/oh-my-posh' '/usr/local/bin/oh-my-posh'
    sudo chmod +x '/usr/local/bin/oh-my-posh'

    # zsh
    cat  <<EOF >> "${HOME}/.zshrc"
export __SHELL_INFORMATION_POSH_258__="zsh@\$ZSH_VERSION@${arch}"
eval "\$(oh-my-posh prompt init zsh --print --config '${themePath}')"
enable_poshtransientprompt
EOF

    # bash
    cat  <<EOF >> "${HOME}/.bashrc"
export __SHELL_INFORMATION_POSH_258__="bash@\$BASH_VERSION@${arch}"
eval "\$(oh-my-posh prompt init bash --print --config '${themePath}')"
EOF

    # pwsh
    prof="${HOME}/.config/powershell/Microsoft.PowerShell_profile.ps1"
    mkdir -p ~/.config/powershell
    touch "${prof}"

    cat <<EOF >> "${prof}"
\$ps = 'pwsh@' + \$PSVersionTable.PSVersion.ToString()
\$env:__SHELL_INFORMATION_POSH_258__ = "\$ps@${arch}"
Invoke-Expression (@(oh-my-posh prompt init 'pwsh' --print --config '${themePath}') -join "\`n")
Enable-PoshTransientPrompt
EOF
fi

if [[ -n ${_BUILD_ARG_SHOVEL} ]]; then
    echo "Activating feature 'shovel'"

    SCOOP="${HOME}/Shovel"
    SCOOP_HOME="${SCOOP}/apps/scoop/current"
    SCOOP_GLOBAL="/opt/Shovel"

    defBranch=${_BUILD_ARG_SHOVEL_BRANCH:-NEW}
    supportURL='https://raw.githubusercontent.com/shovel-org/Dockers/main/support'

    mkdir -p ~/.config/scoop "${SCOOP_GLOBAL}"/{apps,shims} "${SCOOP}"/{apps,shims,buckets,cache}

    git clone --branch "$defBranch" "https://github.com/Ash258/Scoop-Core.git" "${SCOOP_HOME}"
    wget -O- "${supportURL}/config.json" | sed "s/main/${defBranch}/g" > ~/.config/scoop/config.json

    wget -O "${SCOOP}/shims/shovel" "${supportURL}/shovel"
    for ext in $(echo ps1 cmd); do
        wget -O "${SCOOP}/shims/shovel.${ext}" "${supportURL}/shovel.${ext}"
    done

    if [[ -n ${_BUILD_ARG_OH_MY_POSH_LOCALREPO} ]]; then
        mv "${SCOOP_HOME}" "${SCOOP_HOME}.orig"
    fi

    sudo chmod +x "${SCOOP}/shims"/*

    cat <<EOF >> /etc/profile.d/01-shovel.sh
export SCOOP=~/Shovel
export SHOVEL=~/Shovel
export SCOOP_HOME=~/Shovel/apps/scoop/current
export SHOVEL_HOME=~/Shovel/apps/scoop/current
export SCOOP_GLOBAL=/opt/Shovel
export SHOVEL_GLOBAL=/opt/Shovel
export PATH="\$PATH:/opt/Shovel/shims:\$HOME/Shovel/shims"
EOF

    which pwsh 2>/dev/null || echo 'To proper functionality powershell feature needs to be enabled'
fi

if [[ -n ${_BUILD_ARG_SHELLCHECK} ]]; then
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    localShellCheckFile="/bin/shellcheck"
    version="${_BUILD_ARG_SHELLCHECK_VERSION:-latest}"

    if [[ "${version}" == "latest" ]]; then
        latest=$(wget -O- 'https://api.github.com/repos/koalaman/shellcheck/releases/latest' | grep 'tag_name' | sed 's/.*"v\([0-9.]*\)",.*/\1/' )
        version="${latest}"
    fi

    shellcheckUrl="https://github.com/koalaman/shellcheck/releases/download/v${version}/shellcheck-v${version}.${os}.$(uname -m).tar.xz"
    wget -O "${localShellCheckFile}.tar.xz" "${shellcheckUrl}"
    tar xf "${localShellCheckFile}.tar.xz" -C /bin
    mv "${localShellCheckFile}-v${version}/shellcheck" "${localShellCheckFile}"

    rm -rf "${localShellCheckFile}.tar.xz" "${localShellCheckFile}-v${version}/"

    chmod +x "${localShellCheckFile}"
    shellcheck --version
fi
