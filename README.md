# dotfiles-arch

Dotfiles personalizados para **Arch Linux + Hyprland** como entorno de escritorio principal.

---

## Entorno

| Componente | Herramienta |
|---|---|
| Compositor | Hyprland |
| Terminal | Kitty |
| Shell | Zsh + Oh My Zsh + Starship |
| Editor | Neovim (LazyVim) |
| Barra | Waybar |
| Launcher | Rofi |
| Notificaciones | SwayNC |
| Control Center | eww |
| Multiplexor | Tmux |
| File manager | Yazi |
| Wallpaper | swww |
| Plugins Hyprland | hyprpm (hyprexpo, hyprfocus, borders++) |
| Navegador | Brave / Tor |
| Música | Spotify |
| Chat | Discord |

---

## Temas

Dos temas intercambiables con `SUPER + T`:

| | Tokyo Night | Kali (Auditory) |
|---|---|---|
| Cursor | Bibata-Modern-Ice | Bibata-Modern-Classic |
| Iconos | Papirus-Dark (cyan) | Papirus-Dark (rojo) |
| GTK | Tokyonight-Dark | Adwaita-dark |
| Bordes Hyprland | Gradiente cyan → púrpura | Rosa (#ff2d78) |
| Starship | `tokyonight.toml` | `auditory.toml` |
| Btop | tokyo-night | dracula |

El cambio de tema es global: waybar, kitty, rofi, swaync, hyprland, starship, btop, eww y fastfetch cambian al instante.

---

## Instalación

```bash
git clone git@github.com:sreaperr/dotfiles-arch.git ~/dotfiles-arch
cd ~/dotfiles-arch
chmod +x install.sh
./install.sh
```

El script instala todos los paquetes, crea los symlinks, aplica el tema Tokyo Night por defecto y configura la actualización automática.

> **Post-instalación:** Cierra sesión completamente y vuelve a entrar para que los cambios de grupo (docker), shell (zsh) y variables de entorno surtan efecto.

---

## Actualización automática

Al encender el PC (60 segundos después del arranque), `update.sh` actualiza automáticamente:
- Mirrors de pacman (reflector)
- Paquetes del sistema (pacman) y AUR (paru)
- Plugins de Hyprland (hyprpm)
- Plugins de Neovim (lazy.nvim)
- Plugins de Tmux (tpm)

La actualización se omite si ya se ejecutó en las últimas 24 horas. Log en `~/.local/share/update.log`.

También puedes ejecutarlo manualmente:
```bash
~/dotfiles-arch/update.sh
```

---

## Atajos principales

### Hyprland

| Atajo | Acción |
|---|---|
| `SUPER + Enter` | Terminal (Kitty) |
| `SUPER + Space` | Lanzador de apps (Rofi) |
| `SUPER + Tab` | Cambiar ventana activa |
| `SUPER + B` | Brave |
| `SUPER + Y` | Yazi flotante (1000×560) |
| `SUPER + A` | Fastfetch flotante temático |
| `SUPER + C` | Control Center (eww) |
| `SUPER + T` | Cambiar tema (Tokyo Night / Kali) |
| `SUPER + N` | Selector de wallpaper con preview |
| `SUPER + L` | Bloquear pantalla (Hyprlock) |
| `SUPER + I` | Menú de energía |
| `SUPER + H` | Historial portapapeles |
| `SUPER + R` | Grabación de pantalla |
| `SUPER + S` | Conexiones SSH |
| `SUPER + =` | Calculadora |
| `SUPER + Shift + S` | Captura + anotaciones |
| `SUPER + Shift + Space` | Ejecutar comando |
| `SUPER + Flechas` | Navegar ventanas |
| `SUPER + Shift + Flechas` | Mover ventanas |
| `SUPER + Ctrl + Flechas` | Redimensionar ventanas |
| `SUPER + 1–8` | Cambiar workspace |
| `SUPER + Shift + 1–8` | Mover ventana a workspace |
| `SUPER + W` | Cerrar ventana |
| `SUPER + F` | Pantalla completa |
| `SUPER + M` | Intercambiar con ventana maestra |

### Teclas de función (teclado Mac)

| Tecla | Acción |
|---|---|
| `F3` | Ciclar orientación de ventanas |
| `F4` | Overview de workspaces (hyprexpo) |
| `F7 / F8 / F9` | Anterior / Play-Pause / Siguiente |
| `F10 / F11 / F12` | Mute / Volumen − / + |

### Control Center (eww — `SUPER + C`)

Panel lateral derecho con:
- Reloj y fecha, usuario
- Media player con controles
- Toggles: Bluetooth, WiFi, DND, Modo noche
- Sliders de brillo y volumen
- CPU y RAM en tiempo real
- Calendario del mes

### Tmux (`Ctrl+A` como prefijo)

| Atajo | Acción |
|---|---|
| `Prefijo + \|` | Split vertical |
| `Prefijo + -` | Split horizontal |
| `Prefijo + h/j/k/l` | Navegar paneles |
| `Prefijo + s` | Elegir sesión |
| `Prefijo + r` | Recargar config |
| `Shift + ←/→` | Cambiar ventana |

---

## Estructura

```
dotfiles-arch/
├── install.sh               ← instalación completa
├── update.sh                ← actualización del sistema
├── .zshrc / .zprofile       ← configuración de shell
├── .gitconfig               ← configuración de git
├── etc/                     ← configs de sistema
│   ├── pacman.conf
│   ├── reflector.conf
│   └── modprobe.d/
└── .config/
    ├── hypr/                ← hyprland, keybinds, rules, scripts, temas
    │   ├── scripts/         ← theme-switch, wallpaper, powermenu, etc.
    │   └── themes/          ← tokyonight.conf, kali.conf, hyprlock-*.conf
    ├── waybar/              ← barra + scripts de módulos + temas
    ├── eww/                 ← control center (brillo, volumen, BT, calendario)
    │   └── themes/          ← tokyonight.scss, kali.scss
    ├── kitty/               ← terminal + temas
    ├── rofi/                ← launcher + temas (estilo adi1090x)
    ├── nvim/                ← LazyVim
    ├── tmux/
    ├── starship/
    │   └── themes/          ← tokyonight.toml, auditory.toml
    ├── swaync/              ← notificaciones + temas
    ├── fastfetch/           ← config.jsonc (kali), config-tokyonight.jsonc
    ├── yazi/
    ├── btop/
    ├── mpv/
    ├── zathura/
    └── keyd/                ← remapeo teclado Mac
```

---

## Cambiar tema

`SUPER + T` → selecciona Tokyo Night o Kali → cambia todo el sistema al instante.

---

## Troubleshooting

**Hyprland no arranca**
```bash
cat ~/.local/share/hyprland/hyprland.log | tail -50
```

**Los temas no se aplican al arrancar**
```bash
~/.config/hypr/scripts/theme-startup.sh
```

**Los plugins de Hyprland no cargan**
```bash
hyprpm update && hyprpm enable hyprexpo && hyprpm enable hyprfocus && hyprpm enable borders-plus-plus
```

**El control center (eww) no abre**
```bash
eww daemon && eww open control-center
```

**swww no carga el fondo**
```bash
swww query || swww-daemon &
```

**Ver log de actualizaciones**
```bash
cat ~/.local/share/update.log | tail -30
```
