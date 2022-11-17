# dotfiles but windows so it's not really dotfiles and they're really bad

## 60 Days for update rollback
`DISM /Online /Set-OSUninstallWindow /Value:60`

## Windows 11 Colour Theme
`#588152`

## Config Files for apps

### aria2
`%USERPROFILE%\.aria2`

### gallery-dl
`%USERPROFILE%\gallery-dl`

### neovim
`%LOCALAPPDATA%\nvim`

### yt-dlp
`%APPDATA%\yt-dlp`

## Shell Stuff

### CMD Prompt
```
$E[0;31mdarre$E[0;37m@$E[0;33m%userdomain% $E[0;37min $E[0;32m$p $E[0;37m$b $t$h$h$h$_$$$s
```

### Powershell
`%USERPROFILE%\Documents\Powershell`

## Install Apps

```PowerShell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Xyn0gen/dotfiles/main/setup.ps1'))"```
