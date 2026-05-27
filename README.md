# dotfiles

Configuración personal para **Hyprland** en múltiples distribuciones Linux.

---

## Stack

| | |
|---|---|
| Compositor | Hyprland |
| Barra | Waybar |
| Terminal | Kitty + Tmux |
| Shell | Zsh + Oh My Zsh + Starship |
| Editor | Neovim (LazyVim) |
| Launcher | Rofi |
| Notificaciones | SwayNC |
| File manager | Yazi |
| Wallpaper | swww |
| Temas | Tokyo Night · Auditory |

---

## Distros soportadas

| Distro | Gestor de paquetes | Extras |
|---|---|---|
| **Arch Linux** | `pacman` + `paru` (AUR) | — |
| **Fedora** | `dnf` + COPR `solopasha/hyprland` | Flatpak (Flathub) |
| **Debian 13 Trixie** | `apt` + GitHub releases | Flatpak (Flathub) |

> **Debian** requiere **Trixie (13 Testing)** o **Sid** — Hyprland no está empaquetado en Debian Stable.

---

## Temas

Dos temas intercambiables con `SUPER + T`:

| Tema | Paleta | Base |
|---|---|---|
| **Tokyo Night** | Azul · Cyan · Púrpura | [`folke/tokyonight.nvim`](https://github.com/folke/tokyonight.nvim) (night) |
| **Auditory** | Verde oscuro · Menta | [`jpwol/thorn.nvim`](https://github.com/jpwol/thorn.nvim) (forest) |

El cambio de tema aplica simultáneamente a: Hyprland, Waybar, Kitty, Rofi, SwayNC, Tmux, Yazi, Starship, Fastfetch y SwayOSD.
Todos los archivos de tema viven en `.config/themes/<nombre>/` y se aplican mediante symlinks.

---

## Instalación

### Requisitos previos

Antes de ejecutar el instalador necesitas tener:

```bash
sudo apt install -y git curl sudo   # Debian
```

En Debian, el usuario debe estar en el grupo `sudo`. Si no:

```bash
su -c "usermod -aG sudo $USER" root
# cierra sesión y vuelve a entrar
```

### Ejecutar

```bash
git clone https://github.com/sreaperr/dotfiles-arch.git ~/dotfiles-arch
cd ~/dotfiles-arch
chmod +x install.sh
./install.sh
```

Reinicia cuando termine.

### Qué instala el script

#### Arch Linux
- Paquetes via `pacman`
- `paru` (AUR helper) y paquetes AUR: `rofi-wayland`, `brave-bin`, `google-chrome`, `firefox`, `spotify`, `bibata-cursor-theme`, `tokyonight-gtk-theme-git`, `nerd-fonts`, `uwsm`, `pypr`
- Aplica `pacman.conf` y `reflector.conf` del repo

#### Fedora
- Habilita **RPM Fusion** (free + non-free)
- Habilita COPR **`solopasha/hyprland`** — ecosistema Hyprland completo
- Habilita COPR **`erikreider/SwayNotificationCenter`**
- Instala via **Flatpak**: Firefox, Brave, Chrome, Spotify, Discord, Tor Browser
- Instala desde **GitHub releases**: yazi, lazygit, glow, Nerd Fonts, Bibata cursor, TokyoNight GTK

#### Debian (Trixie / Sid)
- Añade repo oficial de **Docker CE** (fallback a `docker.io` si Trixie no está soportado aún)
- Habilita **Flatpak + Flathub**
- Instala desde **GitHub releases**: starship, eza, yazi, lazygit, glow, bandwhich, hyperfine, cliphist, swaync, Nerd Fonts, Bibata cursor, TokyoNight GTK
- Instala via **Flatpak**: Brave, Chrome, Spotify, Discord, Tor Browser

---

## Pasos post-instalación

Estas acciones deben ejecutarse **una vez dentro de la primera sesión de Hyprland** porque necesitan comunicarse con el compositor:

```bash
# Plugins de Hyprland (borders-plus-plus, hyprexpo, hyprfocus)
hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm add https://github.com/VortexCoyote/hyprfocus
hyprpm enable borders-plus-plus
hyprpm enable hyprexpo
hyprpm enable hyprfocus
```

---

## Sincronizar en un equipo existente

```bash
git pull && ./sync.sh
```

`sync.sh` detecta la distro y usa el gestor de paquetes correcto.

---

## Actualización automática

El crontab `@reboot` ejecuta `update.sh` 60 segundos tras arrancar el sistema.
También se puede lanzar manualmente con el alias `update`.

| Distro | Qué actualiza |
|---|---|
| Arch | mirrors (reflector) → pacman → paru (AUR) → hyprpm → neovim → tmux |
| Fedora | dnf → flatpak → hyprpm → neovim → tmux |
| Debian | apt → flatpak → hyprpm → neovim → tmux |

---

## Aliases multi-distro

El `.zshrc` detecta la distro y expone los mismos alias en todas:

| Alias | Arch | Fedora | Debian |
|---|---|---|---|
| `install` | `paru -S` | `dnf install -y` | `apt install -y` |
| `remove` | `paru -Rns` | `dnf remove -y` | `apt remove -y` |
| `search` | `paru -Ss` | `dnf search` | `apt search` |
| `pkginfo` | `paru -Qi` | `dnf info` | `apt show` |
| `update` | `./update.sh` | `./update.sh` | `./update.sh` |
| `cleanup` | `pacman -Rns` huérfanos | `dnf autoremove` | `apt autoremove` |

---

## Atajos esenciales

| Atajo | Acción |
|---|---|
| `SUPER + Enter` | Terminal |
| `SUPER + Space` | Launcher de apps |
| `SUPER + T` | Cambiar tema |
| `SUPER + N` | Selector de wallpaper |
| `SUPER + Y` | Yazi (flotante) |
| `SUPER + L` | Bloquear pantalla |
| `SUPER + I` | Menú de energía |
| `SUPER + 1–8` | Cambiar workspace |
| `SUPER + k` | Calendario |
