#!/bin/bash
# Dos lecturas de /proc/stat separadas 300ms para CPU real-time
r1=$(grep -m1 'cpu ' /proc/stat)
sleep 0.3
r2=$(grep -m1 'cpu ' /proc/stat)

set -- $r1; u1=$(($2+$4)); t1=$(($2+$3+$4+$5+$6+$7+$8+$9))
set -- $r2; u2=$(($2+$4)); t2=$(($2+$3+$4+$5+$6+$7+$8+$9))

echo $(( (u2-u1)*100/(t2-t1) ))
