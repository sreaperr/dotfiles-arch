# dotfiles-arch

Configuración personal para **Arch Linux + Hyprland**.

---

## Stack

| | |
|---|---|
| Compositor | Hyprland |
| Barra | Waybar |
| Terminal | Kitty + Tmux |
| Shell | Zsh + Starship |
| Editor | Neovim (LazyVim) |
| Launcher | Rofi |
| Notificaciones | SwayNC |
| Panel de widgets | eww |
| File manager | Yazi |
| Wallpaper | swww |

## Temas

Dos temas intercambiables con `SUPER + T`:

- **Tokyo Night** — cyan y púrpura
- **Kali (Auditory)** — magenta y verde

El cambio aplica a Hyprland, Waybar, Kitty, Rofi, SwayNC, eww, Tmux, Starship y Fastfetch de forma simultánea.

---

## Instalación

> Requiere Arch Linux con una instalación base funcional.

```bash
git clone https://github.com/sreaperr/dotfiles-arch.git ~/dotfiles-arch
cd ~/dotfiles-arch
chmod +x install.sh
./install.sh
```

Reinicia sesión al terminar.

## Sincronizar en un equipo existente

```bash
git pull && ./sync.sh
```

---

## Atajos esenciales

| Atajo | Acción |
|---|---|
| `SUPER + Enter` | Terminal |
| `SUPER + Space` | Launcher de apps |
| `SUPER + C` | Panel de widgets |
| `SUPER + T` | Cambiar tema |
| `SUPER + N` | Selector de wallpaper |
| `SUPER + Y` | Yazi (flotante) |
| `SUPER + A` | Fastfetch (flotante) |
| `SUPER + L` | Bloquear pantalla |
| `SUPER + I` | Menú de energía |
| `SUPER + 1–8` | Cambiar workspace |
