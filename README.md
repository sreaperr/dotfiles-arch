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
| Multiplexor | Tmux |
| File manager | Yazi |
| Navegador | Brave / Firefox / Tor |
| Música | Spotify |
| Chat | Discord |

---

## Temas

Tres temas intercambiables con un click desde la barra:

| | Gruvbox Dark | Tokyo Night | Kali |
|---|---|---|---|
| Cursor | Bibata-Modern-Amber | Bibata-Modern-Ice | Bibata-Modern-Classic |
| Iconos | Papirus-Dark (naranja) | Papirus-Dark (cyan) | Papirus-Dark (rojo) |
| GTK | Gruvbox-Material-Dark | Tokyonight-Dark | Kali-Dark |
| Bordes | Gradiente ámbar → naranja | Gradiente cyan → púrpura | Rosa (#ff2d78) |

---

## Instalación

```bash
git clone git@github.com:sreaperr/dotfiles-arch.git ~/dotfiles-arch
cd ~/dotfiles-arch
chmod +x install.sh
./install.sh
```

El script instala todos los paquetes, crea los symlinks y aplica el tema Gruvbox por defecto.

> **Post-instalación:** Cierra sesión completamente y vuelve a entrar para que los cambios de grupo (docker), shell (zsh) y variables de entorno surtan efecto.

---

## Atajos principales

### Hyprland
| Atajo | Acción |
|---|---|
| `SUPER + Enter` | Terminal (Kitty) |
| `SUPER + Space` | Lanzador de apps (Rofi) |
| `SUPER + B` | Brave |
| `SUPER + E` | Yazi (file manager) |
| `SUPER + L` | Bloquear pantalla |
| `SUPER + I` | Menú de energía |
| `SUPER + H` | Historial portapapeles |
| `SUPER + R` | Grabación de pantalla |
| `SUPER + S` | Conexiones SSH |
| `SUPER + =` | Calculadora |
| `SUPER + Tab` | Cambiar ventana |
| `SUPER + Shift + S` | Captura + anotaciones |
| `SUPER + Flechas` | Navegar ventanas |
| `SUPER + Shift + Flechas` | Mover ventanas |
| `SUPER + 1-8` | Cambiar workspace |
| `SUPER + Shift + Q` | Cerrar ventana |

### Teclas de función (teclado Mac)
| Tecla | Acción |
|---|---|
| `F1 / F2` | Brillo − / + |
| `F3` | Ciclar orientación ventanas |
| `F4` | Lanzador de apps |
| `F7 / F8 / F9` | Anterior / Play-Pause / Siguiente |
| `F10 / F11 / F12` | Mute / Volumen − / + |
| `Fn + F1-F12` | Teclas F estándar |

### Tmux (`Ctrl+A` como prefijo)
| Atajo | Acción |
|---|---|
| `Prefijo + |` | Split vertical |
| `Prefijo + -` | Split horizontal |
| `Prefijo + h/j/k/l` | Navegar paneles |
| `Prefijo + s` | Elegir sesión |
| `Prefijo + r` | Recargar config |
| `Shift + ←/→` | Cambiar ventana |

---

## Estructura

```
dotfiles-arch/
├── install.sh               ← script de instalación
├── .zshrc / .zprofile       ← configuración de shell
├── .gitconfig               ← configuración de git
├── .ssh/config              ← hosts SSH
├── etc/                     ← configs de sistema
│   ├── pacman.conf
│   ├── reflector.conf
│   └── modprobe.d/
├── .config/
│   ├── hypr/                ← hyprland, keybinds, rules, scripts, temas
│   ├── waybar/              ← barra + temas
│   ├── kitty/               ← terminal + temas
│   ├── rofi/                ← launcher + temas
│   ├── nvim/                ← LazyVim
│   ├── tmux/
│   ├── starship/
│   ├── swaync/              ← notificaciones + temas
│   ├── fastfetch/
│   ├── yazi/
│   ├── btop/
│   ├── mpv/
│   ├── zathura/
│   ├── keyd/                ← remapeo teclado Mac
│   └── gtk-3.0 / gtk-4.0   ← tema GTK
```

---

## Cambiar tema

Click en el icono `󰏘` de la barra → selecciona Gruvbox, Tokyo Night o Kali → cambia todo el sistema al instante.

---

## Dependencias de scripts

Los scripts de `.config/hypr/scripts/` requieren: `rofi`, `hyprctl`, `awww`, `notify-send`, `gsettings`, `papirus-folders`. Todos se instalan con `install.sh`.

---

## Troubleshooting

**Hyprland no arranca**
```bash
# Revisa el log de la última sesión
cat ~/.local/share/hyprland/hyprland.log | tail -50
```

**Los temas no se aplican al arrancar**
```bash
# Ejecuta manualmente el script de arranque
~/.config/hypr/scripts/theme-startup.sh
```

**Iconos o cursor incorrectos tras reiniciar**
```bash
# El cursor guardado puede estar desincronizado; aplica el tema manualmente
~/.config/hypr/scripts/theme-switch.sh
```

**awww no carga el fondo**
```bash
# Comprueba que el daemon esté corriendo
awww query || awww init
```

---

## Flujo de trabajo git

```bash
# Hacer cambios y subir
git add .
git commit -m "descripción"
git push

# Sincronizar desde otro equipo
git pull
```
