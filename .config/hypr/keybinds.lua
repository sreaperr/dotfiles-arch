--============================
-- KEYBINDS DE DOTFILES ARCH
--============================
-- SUPER = tecla Windows / Meta

local mainMod = "SUPER"

--------------
-- APLICACIONES
--------------
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + y",      hl.dsp.exec_cmd("~/.config/hypr/scripts/yazi-float.sh"))
hl.bind(mainMod .. " + b",      hl.dsp.exec_cmd("brave"))
hl.bind(mainMod .. " + space",  hl.dsp.exec_cmd("~/.config/rofi/launchers/type-1/launcher.sh"))

-----------
-- CAPTURAS  (flameshot → portapapeles)
-----------
hl.bind("Print",          hl.dsp.exec_cmd("~/.config/rofi/applets/bin/screenshot.sh"))
hl.bind("SHIFT + Print",  hl.dsp.exec_cmd("flameshot full -c"))

-----------
-- ENTORNO
-----------
hl.bind(mainMod .. " + t", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper-picker.sh"))
hl.bind(mainMod .. " + w", hl.dsp.window.close())

--------
-- SISTEMA
--------
hl.bind(mainMod .. " + SHIFT + e", hl.dsp.exit())
hl.bind(mainMod .. " + f",         hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + f", hl.dsp.window.float({ action = "toggle" }))
-- Se mantiene vía hyprctl dispatch: la forma nativa de encadenar resize exacto + centrar
-- aún no está verificada para este build — si prefieres la API nativa, prueba
-- hl.dsp.window.resize({ x = 1200, y = 700, exact = true }) seguido de hl.dsp.window.center()
hl.bind(mainMod .. " + CTRL + f", hl.dsp.exec_cmd("hyprctl dispatch resizeactive exact 1200 700 && hyprctl dispatch centerwindow"))
hl.bind(mainMod .. " + SHIFT + p", hl.dsp.window.pin({ action = "toggle" }))
hl.bind(mainMod .. " + l", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + i", hl.dsp.exec_cmd("~/.config/rofi/powermenu/type-2/powermenu.sh"))

------------------------
-- PANEL Y HERRAMIENTAS
------------------------
hl.bind(mainMod .. " + h", hl.dsp.exec_cmd([[cliphist list | rofi -dmenu -p "  Portapapeles" -theme ~/.config/rofi/runner.rasi | cliphist decode | wl-copy]]))
hl.bind(mainMod .. " + k", hl.dsp.exec_cmd("~/.config/hypr/scripts/calcurse-float.sh"))
hl.bind(mainMod .. " + v", hl.dsp.exec_cmd("~/.config/rofi/applets/bin/volume.sh"))

-----------------------
-- TECLAS DE FUNCIÓN
-----------------------
-- F3 → ciclar orientación de ventanas del layout master (horizontal/vertical/etc.)
hl.bind("f3", hl.dsp.layout("orientationcycle"))
-- F4 → vista general de workspaces con miniaturas en vivo
hl.bind("f4", hl.dsp.exec_cmd("pkill -USR1 hyprexpose"))
-- Teclas multimedia — funcionan en cualquier teclado con teclas media dedicadas
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
-- F7-F12 como controles de media y volumen
hl.bind("f7",  hl.dsp.exec_cmd("playerctl previous"),                     { locked = true })
hl.bind("f8",  hl.dsp.exec_cmd("playerctl play-pause"),                   { locked = true })
hl.bind("f9",  hl.dsp.exec_cmd("playerctl next"),                         { locked = true })
hl.bind("f10", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh mute"),  { locked = true })
hl.bind("f11", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh down"),  { locked = true, repeating = true })
hl.bind("f12", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh up"),    { locked = true, repeating = true })

------
-- AUDIO
------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh up"),       { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh down"),     { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh mute"),     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh mic-mute"), { locked = true })

-------
-- BRILLO
-------
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("ddcutil setvcp 10 + 10 --display 1 & ddcutil setvcp 10 + 10 --display 2"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("ddcutil setvcp 10 - 10 --display 1 & ddcutil setvcp 10 - 10 --display 2"), { locked = true, repeating = true })

--------------------------------------
-- NAVEGACIÓN DE VENTANAS (master layout)
--------------------------------------
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Mover ventanas
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Redimensionar ventanas (deltas relativos vía hyprctl — misma nota que arriba sobre window.resize())
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive -30 0"),  { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 30 0"),    { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -30"),   { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 30"),    { repeating = true })

-- Cambiar ventana maestra
hl.bind(mainMod .. " + m", hl.dsp.layout("swapwithmaster"))

-----------
-- WORKSPACES
-----------
-- Cambiar workspace con mainMod + [0-9] / mover ventana con mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 mapea a la tecla 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Navegar entre workspaces con scroll sobre la barra
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

------
-- RATÓN
------
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-----------
-- LOCAL (máquina específica, gitignored)
-----------
require("keybinds-local")
