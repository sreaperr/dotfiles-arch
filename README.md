```
  ███████╗██████╗ ███████╗ █████╗ ██████╗ ███████╗██████╗
  ██╔════╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗
  ███████╗██████╔╝█████╗  ███████║██████╔╝█████╗  ██████╔╝
  ╚════██║██╔══██╗██╔══╝  ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
  ███████║██║  ██║███████╗██║  ██║██║     ███████╗██║  ██║
  ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
```

Dotfiles personales para **Arch Linux + Hyprland**.

---

## Stack

| | |
|---|---|
| Compositor | Hyprland |
| Barra | Waybar |
| Terminal | Kitty + Tmux |
| Shell | Zsh + Oh My Zsh + Oh My Posh |
| Editor | Neovim (LazyVim) |
| Launcher | Rofi |
| Notificaciones | SwayNC |
| Scratchpads | Pyprland |
| File manager | Yazi · Thunar |
| ls / tree | eza |
| cat / pager | bat |
| cd inteligente | zoxide |
| Git diff | delta |
| Git TUI | lazygit |
| Wallpaper | awww |
| Fetch | Fastfetch |
| Temas | Tokyo Night Night |

---

Wallpapers intercambiables con `SUPER + T`:

---

## Instalación

### Requisitos

- Arch Linux con usuario no root
- Conexión a internet
- Git instalado (`sudo pacman -S git`)

> **El repo debe clonarse en `$HOME/dotfiles-arch`.**
> El script de instalación usa esa ruta fija. Si se clona en otro directorio, fallará.

> **Solo para instalaciones limpias.**
> ** La mejor opción es instalar todo el SETUP desde arch con terminal. Os dejare una .ova por el repo con usuario y contraseña inicial para que podais instalarlo desde cero.
> `install.sh` no comprueba si los paquetes o directorios ya existen (ej. `~/.tmux/plugins/tpm`).
> Si necesitas reinstalar en un sistema existente, usa `update-local.sh` en su lugar.

### Clonar y ejecutar

```bash
git clone https://github.com/sreaperr/dotfiles-arch.git ~/dotfiles-arch
cd ~/dotfiles-arch
chmod +x install.sh
./install.sh
```

El script hace lo siguiente en orden:

1. Actualiza los repos con `pacman -Syu`
2. Instala `paru` (AUR helper)
3. Instala todos los paquetes de pacman y AUR
4. Instala TPM (gestor de plugins de tmux)
5. Activa servicios: NetworkManager, bluetooth
6. Crea carpetas de usuario en español
7. Instala oh-my-zsh
8. Copia `.config/` del repo a `~/.config/`
9. Copia `pacman.conf` y `reflector.conf` al sistema
10. Cambia la shell a zsh

Reinicia cuando termine.

## Herramientas de pentesting

`tools.sh` instala un set curado de herramientas de pentesting/CTF (no el
repo BlackArch completo, que era demasiado lento). Requiere `paru` ya
instalado, así que se ejecuta después de `install.sh`:

```bash
./tools.sh
```

Incluye reconocimiento (`nmap`, `gobuster`, `ffuf`, `nikto`, `whatweb`),
explotación web (`sqlmap`, `wpscan`, `burpsuite`), explotación/post-explotación
(`metasploit`, `netcat`, `socat`), cracking (`hydra`, `john`, `hashcat`),
análisis de red (`wireshark`, `tcpdump`) y enumeración SMB (`smbclient`,
`smbmap`, `enum4linux`), más `nuclei` para escaneo de plantillas.

## Sincronizar en un equipo existente

Si ya tienes el repo clonado y quieres aplicar los últimos cambios a tu `~/.config/` local:

```bash
git pull
./update-local.sh
```

---

## Atajos esenciales

| Atajo | Acción |
|---|---|
| `SUPER + Enter` | Terminal (Kitty) |
| `SUPER + Space` | Launcher de apps (Rofi) |
| `SUPER + T` | Cambiar wallpaper |
| `SUPER + Y` | Yazi flotante |
| `SUPER + K` | Calcurse flotante |
| `SUPER + L` | Bloquear pantalla |
| `SUPER + I` | Menú de energía |
| `SUPER + H` | Historial del portapapeles |
| `SUPER + W` | Cerrar ventana |
| `SUPER + F` | Fullscreen |
| `SUPER + SHIFT + F` | Flotar ventana |
| `F4` | Widgets |
| `SUPER + 1–0` | Cambiar workspace |
| `SUPER + SHIFT + 1–0` | Mover ventana a workspace |

---

## Estructura

```
dotfiles-arch/
├── .config/          # Configuraciones de apps
│   ├── hypr/         # Hyprland + scripts
│   ├── waybar/       # Barra de estado
│   ├── rofi/         # Launcher y menús
│   ├── kitty/        # Terminal (tema Tokyo Night)
│   ├── nvim/         # Neovim (LazyVim)
│   ├── tmux/         # Multiplexor de terminal
│   ├── zsh/          # Config de zsh (aliases.zsh, highlight.zsh)
│   ├── bat/          # Pager con tema tokyonight_night
│   ├── eza/          # Colores Tokyo Night para ls
│   ├── lazygit/      # Git TUI con tema Tokyo Night
│   ├── fastfetch/    # Fetch con colores Tokyo Night
│   ├── yazi/         # File manager con tema Tokyo Night
│   ├── btop/         # Monitor con tema Tokyo Night
│   ├── themes/       # Temas (desktop)
│   └── ...
├── etc/              # Configs del sistema
│   ├── pacman.conf
│   └── reflector.conf
├── .zshrc
├── .zprofile
├── .gitconfig
├── install.sh        # Instalación limpia
├── tools.sh           # Herramientas de pentesting/CTF
└── update-local.sh   # Sincronizar configs locales
```

---

## Créditos

Partes de esta configuración están basadas o inspiradas en los siguientes proyectos:

| Proyecto | Autor | Uso |
|---|---|---|
| [mechabar](https://github.com/sejjy/mechabar) | [sejjy](https://github.com/sejjy) | Base de la configuración de Waybar |
| [rofi-themes-collection](https://github.com/adi1090x/rofi) | [adi1090x](https://github.com/adi1090x) | Launchers, applets, powermenu y paletas de colores de rofi |
| [rofi-themes](https://github.com/fishyfishfish55/rofi-themes) | [fishyfishfish55](https://github.com/fishyfishfish55) | Paleta tokyonight para rofi |
| [catppuccin/waybar](https://github.com/catppuccin/waybar) | [Catppuccin](https://github.com/catppuccin) | Temas catppuccin de waybar |
| [yazi-rs/plugins](https://github.com/yazi-rs/plugins) | [yazi-rs](https://github.com/yazi-rs) | Plugins de yazi: git, diff, jump-to-char, smart-enter |
| [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | [folke](https://github.com/folke) | Tema Tokyo Night para kitty, eza, lazygit, delta, fzf, bat |
