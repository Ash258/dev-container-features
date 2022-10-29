# Available features

## oh-my-posh

Will install oh-my-posh with custom theme.

Properties:

- `themeFile`: URL to theme

## shovel

Properies:

- `branch`: name of the branch to be used for core installation
- `localRepo`: Use workspace mounted folder as $SHOVEL_HOME

## shellcheck

Install shellcheck

# Test

```bash
# Manually create devcontainer-features.env
docker run -v "${PWD}:/test" -ti mcr.microsoft.com/vscode/devcontainers/base:alpine bash
cd /test
test -f devcontainer-features.env || cp devcontainer-features.env.example devcontainer-features.env
./install.sh
```
