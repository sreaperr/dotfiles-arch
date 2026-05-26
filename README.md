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
| Tema | Tokyo Night / Kali (Auditory) |

---

## Distros soportadas

| Distro | Gestor de paquetes | Paquetes extra |
|---|---|---|
| **Arch Linux** | `pacman` + `paru` (AUR) | — |
| **Fedora** | `dnf` + COPR `solopasha/hyprland` | Flatpak (Flathub) |
| **Debian** | `apt` + GitHub releases | Flatpak (Flathub) |

> **Debian** requiere **Sid (unstable)** o **Testing** para tener Hyprland disponible en `apt`.
> En Debian Stable, los paquetes del ecosistema Wayland/Hyprland son demasiado antiguos.

---

## Temas

Dos temas intercambiables con `SUPER + T`:

- **Tokyo Night** — cyan y púrpura
- **Kali (Auditory)** — magenta y verde

El cambio aplica simultáneamente a: Hyprland, Waybar, Kitty, Rofi, SwayNC, Tmux, Yazi, Starship y Fastfetch.

---

## Instalación

El mismo script detecta la distro automáticamente al ejecutarse:

```bash
git clone https://github.com/sreaperr/dotfiles-arch.git ~/dotfiles-arch
cd ~/dotfiles-arch
chmod +x install.sh
./install.sh
```

Reinicia sesión al terminar.

### Qué hace el instalador por distro

#### Arch Linux
- Instala paquetes con `pacman`
- Instala `paru` (AUR helper) y paquetes AUR: `rofi-wayland`, `brave-bin`, `spotify`, `bibata-cursor-theme`, `tokyonight-gtk-theme-git`, `nerd-fonts`, etc.
- Aplica `pacman.conf` y `reflector.conf` del repo

#### Fedora
- Habilita **RPM Fusion** (free + non-free)
- Habilita COPR **`solopasha/hyprland`** — ecosistema Hyprland completo
- Habilita COPR **`erikreider/SwayNotificationCenter`** — swaync
- Instala paquetes con `dnf`
- Instala via **Flatpak** (Flathub): Brave, Spotify, Discord, Tor Browser
- Instala desde **GitHub releases**: yazi, lazygit, glow, Nerd Fonts, Bibata cursor, TokyoNight GTK

#### Debian (Sid/Testing)
- Añade repo oficial de **Docker CE**
- Habilita **Flatpak + Flathub**
- Instala paquetes con `apt`
- Instala desde **GitHub releases**: starship, eza, yazi, lazygit, glow, fastfetch, bandwhich, hyperfine, cliphist, Nerd Fonts, Bibata cursor, TokyoNight GTK
- Instala via **Flatpak**: Brave, Spotify, Discord, Tor Browser

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
| `SUPER + k` | Calendar |
