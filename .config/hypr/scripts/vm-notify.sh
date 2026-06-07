#!/bin/bash
# Notificación con DBUS de sesión explícito para exec de Hyprland
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
notify-send "$@"
