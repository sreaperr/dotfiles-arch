#!/bin/bash
# Alterna el filtro de luz azul nocturna (wlsunset)
if pgrep -x wlsunset > /dev/null; then
    pkill wlsunset
else
    wlsunset -l 40.4 -L -3.7 &
fi
