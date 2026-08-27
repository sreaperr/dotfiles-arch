--==========================
-- HYPRLAND DE DOTFILES ARCH
-- Migrado de hyprland.conf (hyprlang) a Lua — Hyprland 0.55+
--==========================

--------------------
-- ARCHIVOS EXTERNOS
--------------------
require("theme")
require("rules")
require("keybinds")

------------
-- MONITORES
------------
-- Auto — kanshi sobreescribe con el perfil correcto una vez detecta los monitores
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-----------
-- AUTOSTART
-----------
hl.on("hyprland.start", function()
    -- Arranca awww-daemon inmediatamente para evitar pantallas grises al login
    hl.exec_cmd("~/.config/hypr/scripts/start-wallpaper.sh")
    -- Barra de estado
    hl.exec_cmd("systemctl --user start waybar")
    -- Notificaciones
    hl.exec_cmd("swaync")
    -- Portapapeles
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    -- Agente de autenticación
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    -- Automontaje de USBs
    hl.exec_cmd("udiskie &")
    -- NetworkManager applet
    hl.exec_cmd("nm-applet --indicator")
    -- Daemon de inactividad
    hl.exec_cmd("hypridle")
    -- Aplicar tema según OS al arrancar
    hl.exec_cmd("~/.config/hypr/scripts/theme-startup.sh")
    -- Plugins — hyprpm los compila para la versión instalada y los carga todos de una
    hl.exec_cmd("hyprpm reload -n")
    -- Pyprland — scratchpads y plugins de Hyprland en espacio de usuario
    hl.exec_cmd("pypr")
    -- Monitor profiles — detecta qué pantallas hay conectadas y aplica el perfil correcto
    hl.exec_cmd("kanshi")
    -- OSD de volumen y brillo en pantalla (swayosd-client en keybinds)
    hl.exec_cmd("swayosd-server")
    -- Notificaciones de Spotify al cambiar canción
    hl.exec_cmd("~/.config/hypr/scripts/spotify-notify.sh")
    -- Vista general de workspaces (F4 manda SIGUSR1 para toggle)
    hl.exec_cmd("hyprexpose")
end)

---------------------
-- VARIABLES DE ENTORNO
---------------------
hl.env("XCURSOR_THEME", "LHackneyed-Dark-24px")
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

--------
-- GENERAL
--------
hl.config({
    general = {
        gaps_in          = 8,
        gaps_out         = 20,
        border_size      = 1,
        resize_on_border = true,
        layout           = "master",
        -- colores de borde definidos en theme.lua — no poner aquí o sobreescriben el tema
    },
})

-----------------------------------
-- DECORACIÓN (bordes, blur, sombras)
-----------------------------------
hl.config({
    decoration = {
        rounding = 16,

        blur = {
            enabled           = true,
            size              = 12,
            passes            = 3,
            new_optimizations = true,
            xray              = false,
            ignore_opacity    = false,
            noise             = 0.0117,
        },

        shadow = {
            enabled      = true,
            range        = 50,
            render_power = 3,
            color        = "rgba(000000bb)",
            -- color_inactive definido en theme.lua
        },

        inactive_opacity = 1.0,
        active_opacity   = 1.0,

        dim_inactive = false,
        -- Intensidad del oscurecido alrededor de ventanas flotantes (activado por windowrule en rules.lua)
        dim_around   = 0.4,
    },
})

------------
-- ANIMACIONES
------------
hl.config({ animations = { enabled = true } })

-- ── CURVAS BEZIER ───────────────────────────────────────────────
-- Entrada: easeOutBack — arranca, decelera y tiene un micro-overshoot al llegar
hl.curve("springOpen", { type = "bezier", points = { { 0.18, 0.89 }, { 0.32, 1.12 } } })
-- Salida: empieza rápido y frena brevemente al final
hl.curve("quickClose", { type = "bezier", points = { { 0.25, 0 }, { 0.5, 0.4 } } })
-- Workspaces: easeOutQuad — momentum inicial que frena suave
hl.curve("slideEase", { type = "bezier", points = { { 0.25, 0.46 }, { 0.45, 0.94 } } })
-- Fade: easeOutExpo — transición sutil, casi imperceptible
hl.curve("fadeEase", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

-- ── VENTANAS ────────────────────────────────────────────────────
-- Entrada: parte del 87% del tamaño final (efecto popin)
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 3,   bezier = "springOpen", style = "popin 87%" })
-- Salida: más rápida que la entrada
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "quickClose", style = "popin 87%" })
-- Movimiento y resize: fluido, sin rebote (antes "windowsMove", ahora leaf "windows")
hl.animation({ leaf = "windows",    enabled = true, speed = 3,   bezier = "slideEase" })

-- ── BORDES ──────────────────────────────────────────────────────
hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "linear" })

-- ── FADE ────────────────────────────────────────────────────────
hl.animation({ leaf = "fadeIn",  enabled = true, speed = 2,   bezier = "fadeEase" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.5, bezier = "quickClose" })
-- NOTA: "fadeDim" y "fadeShadow" ya no existen como leaves separados en 0.55+;
-- ambos tenían los mismos valores (fadeEase, speed 3) así que se consolidan en "fade".
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "fadeEase" })

-- ── CAPAS (waybar, rofi, swaync) ────────────────────────────────
hl.animation({ leaf = "layersIn",  enabled = true, speed = 2.5, bezier = "springOpen", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "quickClose", style = "fade" })
-- "fadeLayers" se dividió en fadeLayersIn/fadeLayersOut; mismo valor para ambas
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 2, bezier = "fadeEase" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2, bezier = "fadeEase" })

-- ── WORKSPACES ──────────────────────────────────────────────────
-- Slide horizontal suave con inercia que frena al llegar
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "slideEase", style = "slide" })
-- NOTA: "specialWorkspace" ya no existe como leaf independiente en 0.55+.
-- Aproximación con workspacesIn/workspacesOut + style "slidevert" — verificar visualmente.
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 4, bezier = "slideEase", style = "slidevert" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 4, bezier = "slideEase", style = "slidevert" })

--------------
-- LAYOUT MASTER
--------------
hl.config({
    master = {
        new_status  = "slave",
        mfact       = 0.55,
        orientation = "left",
    },
})

------------------------
-- INPUT (teclado y ratón)
------------------------
hl.config({
    input = {
        kb_layout  = "es",
        kb_model   = "pc105",
        -- terminate:ctrl_alt_bksp → Ctrl+Alt+Retroceso mata el servidor gráfico
        kb_options = "terminate:ctrl_alt_bksp",

        follow_mouse = 1,

        -- sensitivity: -1.0 (lento) a 1.0 (rápido), 0 es el valor por defecto
        sensitivity   = 0,
        accel_profile = "adaptive",
    },
})

-------
-- GESTOS
-------
hl.config({
    gestures = {
        workspace_swipe_distance     = 300,
        workspace_swipe_cancel_ratio = 0.5,
    },
})

-----
-- MISC
-----
hl.config({
    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        focus_on_activate        = true,
        vrr                      = 2, -- adaptive sync solo en fullscreen (menos bugs que vrr=1)
    },
})

hl.config({
    cursor = {
        no_hardware_cursors = true, -- evita artefactos de cursor en AMD iGPU
    },
})

-----------
-- WORKSPACES
-----------
-- 1-8 en el ultrawide (DP-1), 9-10 en el monitor secundario (HDMI-A-1)
hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-1" })
hl.workspace_rule({ workspace = "3", monitor = "DP-1" })
hl.workspace_rule({ workspace = "4", monitor = "DP-1" })
hl.workspace_rule({ workspace = "5", monitor = "DP-1" })
hl.workspace_rule({ workspace = "6", monitor = "DP-1" })
hl.workspace_rule({ workspace = "7", monitor = "DP-1" })
hl.workspace_rule({ workspace = "8", monitor = "DP-1" })
hl.workspace_rule({ workspace = "9", monitor = "HDMI-A-1", default = true })
hl.workspace_rule({ workspace = "10", monitor = "HDMI-A-1" })
