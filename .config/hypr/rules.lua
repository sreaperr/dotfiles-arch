--===================
-- REGLAS DE VENTANAS
-- Sintaxis Lua (Hyprland 0.55+): hl.window_rule({ name, match = {}, propiedades })
--===================

-- ── Scratchpads (pyprland) ────────────────────────────────────────────────────
hl.window_rule({
    name  = "scratchpad-clock",
    match = { class = "^scratchpad-clock$" },
    float = true,
})
hl.window_rule({
    name  = "scratchpad-fetch",
    match = { class = "^scratchpad-fetch$" },
    float = true,
})
hl.window_rule({
    name  = "scratchpad-btop",
    match = { class = "^scratchpad-btop$" },
    float = true,
})
hl.window_rule({
    name  = "scratchpad-keys",
    match = { class = "^scratchpad-keys$" },
    float = true,
})

hl.window_rule({
    name    = "opacity-scratchpads",
    match   = { class = "^scratchpad-" },
    opacity = "0.85 0.85",
})

-- ── Apps flotantes ────────────────────────────────────────────────────────────

hl.window_rule({
    name   = "pavucontrol",
    match  = { class = "^org.pulseaudio.pavucontrol$" },
    float  = true,
    size   = "800 600",
    center = true,
})

hl.window_rule({
    name   = "blueman-manager",
    match  = { class = "^blueman-manager$" },
    float  = true,
    size   = "900 600",
    center = true,
})

hl.window_rule({
    name   = "thunar",
    match  = { class = "^thunar$" },
    float  = true,
    size   = "1100 700",
    center = true,
})

hl.window_rule({
    name           = "dolphin",
    match          = { class = "^org\\.kde\\.dolphin$" },
    float          = true,
    size           = "1100 700",
    center         = true,
    dim_around     = false,
    suppress_event = "activate",
})

hl.window_rule({
    name   = "nm-connection-editor",
    match  = { class = "^nm-connection-editor$" },
    float  = true,
    size   = "900 600",
    center = true,
})

hl.window_rule({
    name           = "spotify",
    match          = { class = "^Spotify$" },
    float          = true,
    size           = "1200 800",
    center         = true,
    suppress_event = "activate",
})

hl.window_rule({
    name   = "imv",
    match  = { class = "^imv$" },
    float  = true,
    size   = "1200 800",
    center = true,
})

hl.window_rule({
    name         = "mpv",
    match        = { class = "^mpv$" },
    float        = true,
    idle_inhibit = "fullscreen",
})

-- ── Opacidad por app ──────────────────────────────────────────────────────────

hl.window_rule({
    name    = "opacity-kitty",
    match   = { class = "^kitty$" },
    opacity = "0.88 0.88",
})

-- ── Discord ───────────────────────────────────────────────────────────────────

hl.window_rule({
    name           = "discord",
    match          = { class = "^discord$" },
    suppress_event = "activate",
})

-- ── Idle inhibit cuando cualquier ventana está en fullscreen ──────────────────

hl.window_rule({
    name         = "idle-inhibit-fullscreen",
    match        = { fullscreen = true },
    idle_inhibit = "fullscreen",
})

-- ── Animación popin para ventanas flotantes ───────────────────────────────────

hl.window_rule({
    name      = "anim-popin-floats",
    match     = { float = true },
    animation = "popin",
})

-- ── Terminales flotantes (scripts) ────────────────────────────────────────────

hl.window_rule({
    name   = "yazi-term",
    match  = { class = "^yazi-term$" },
    float  = true,
    size   = "1000 560",
    center = true,
})

hl.window_rule({
    name   = "calcurse-term",
    match  = { class = "^calcurse-term$" },
    float  = true,
    size   = "900 580",
    center = true,
})

-- ── Extras flotantes ─────────────────────────────────────────────────────────

hl.window_rule({
    name   = "gnome-system-monitor",
    match  = { class = "^gnome-system-monitor$" },
    float  = true,
    size   = "900 650",
    center = true,
})

hl.window_rule({
    name   = "gnome-calculator",
    match  = { class = "^org.gnome.Calculator$" },
    float  = true,
    size   = "400 600",
    center = true,
})

-- ── Specter HUD — overlay sin foco, sin dim ──────────────────────────────────

hl.window_rule({
    name           = "specter-hud",
    match          = { class = "^specter-hud$" },
    float          = true,
    pin            = true,
    dim_around     = false,
    suppress_event = "activate",
})

-- ── Layer rules — blur en capas del compositor ────────────────────────────────

hl.layer_rule({
    name         = "blur-waybar",
    match        = { namespace = "^waybar$" },
    blur         = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name         = "blur-rofi",
    match        = { namespace = "^rofi$" },
    blur         = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name         = "blur-swaync-cc",
    match        = { namespace = "^swaync-control-center$" },
    blur         = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name         = "blur-swaync-notif",
    match        = { namespace = "^swaync-notification-window$" },
    blur         = true,
    ignore_alpha = 0,
})
