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
| Wallpaper | awww |
| Temas | GreyScale |

---

Tres temas intercambiables con `SUPER + T`:

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
| `SUPER + T` | Cambiar tema |
| `SUPER + Y` | Yazi flotante |
| `SUPER + K` | Calcurse flotante |
| `SUPER + L` | Bloquear pantalla |
| `SUPER + I` | Menú de energía |
| `SUPER + H` | Historial del portapapeles |
| `SUPER + B` | Brave |
| `SUPER + W` | Cerrar ventana |
| `SUPER + F` | Fullscreen |
| `SUPER + SHIFT + F` | Flotar ventana |
| `F4` | Menú de atajos de teclado |
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
│   ├── kitty/        # Terminal
│   ├── nvim/         # Neovim (LazyVim)
│   ├── tmux/         # Multiplexor de terminal
│   ├── zsh/          # Config de zsh (aliases.zsh, highlight.zsh)
│   ├── themes/       # Temas (desktop, auditory)
│   └── ...
├── etc/              # Configs del sistema
│   ├── pacman.conf
│   └── reflector.conf
├── .zshrc
├── .zprofile
├── .gitconfig
├── install.sh        # Instalación limpia
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
