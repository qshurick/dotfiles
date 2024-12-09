# Git configuration

## Howo to setup several git profiles on the same machine

This might be useful in case it is needed to use different profiles to work on different projects, e.g. work/personal, or for different clients. This information is based on [this](https://www.freecodecamp.org/news/how-to-handle-multiple-git-configurations-in-one-machine/) article.

As many tools, git is aware of `$XDG_CONFIG_HOME/git/config`, and will read
this configuration.

```config
[includeIf "gitdir:/path/to/root"]
    path=/path/to/specific/profile
```

General idea is to have projects that should use different profiles in
different root directories, and optionaly load configuration path-based.

```config
; ~/.config/git/config
[includeIf "gitdir:~/projects/"]
    path=~/.config/git/qshurick-config
[includeIf "gitdir:~/work/"]
    path=~/.config/git/work-config

; ~/.config/git/qshurick-config
[user]
name=qshurick
email=qshurick@examle.com

; ~/.config/git/work-config
[user]
name=Full Name
email=work@example.com
```

To verify that correnct configuration is loaded run

```shell
git config -l
```
