# Available features

## oh-my-posh

Will install oh-my-posh with custom theme.

```json
"features": {
    "Ash258/dev-container-features/oh-my-posh": {}
}
```

## Options

| Options Id  | Description                   | Type   | Default Value                                                                               |
| ----------- | ----------------------------- | ------ | ------------------------------------------------------------------------------------------- |
| `themeFile` | URL to the configuration file | string | <https://raw.githubusercontent.com/Ash258/Shovel-Ash258/main/support/oh-my-posh/Ash258.yml> |

## shovel

```json
"features": {
    "Ash258/dev-container-features/shovel": {}
}
```

| Options Id  | Description                                         | Type    | Default Value |
| ----------- | --------------------------------------------------- | ------- | ------------- |
| `branch`    | Name of the branch to be used for core installation | string  | `NEW`         |
| `localRepo` | Use workspace mounted folder as $SHOVEL_HOME        | boolean | false         |

## shellcheck

Install shellcheck

```json
"features": {
    "Ash258/dev-container-features/shellcheck": {
        "version": "0.8.0"
    }
}
```

| Options Id | Description                                    | Type   | Default Value |
| ---------- | ---------------------------------------------- | ------ | ------------- |
| `version`  | Specific version of shellcheck to be installed | string | `latest`      |

# Test

```bash
# Manually create devcontainer-features.env
docker run -v "${PWD}:/test" -w '/test' -ti mcr.microsoft.com/vscode/devcontainers/base:alpine bash
test -f devcontainer-features.env || cp devcontainer-features.env.example devcontainer-features.env
./install.sh
```
