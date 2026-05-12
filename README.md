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

Dos temas intercambiables con un click desde la barra:

| | Gruvbox Dark | Tokyo Night |
|---|---|---|
| Cursor | Bibata-Modern-Amber | Bibata-Modern-Ice |
| Iconos | Kora-dark | Kora-dark |
| GTK | Gruvbox-Material-Dark | Tokyonight-Dark |
| Bordes | Gradiente ámbar → naranja | Gradiente cyan → púrpura |

---

## Instalación

```bash
git clone git@github.com:sreaperr/dotfiles-arch.git ~/dotfiles-arch
cd ~/dotfiles-arch
chmod +x install.sh
./install.sh
```

El script instala todos los paquetes, crea los symlinks y aplica el tema Gruvbox por defecto.

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

Click en el icono `󰏘` de la barra → selecciona Gruvbox o Tokyo Night → cambia todo el sistema al instante.

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
