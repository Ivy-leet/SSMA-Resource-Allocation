spin -a resource_allocation.pml
gcc -DMEMLIM=1024 -DVECTORSZ=2048 -O2 -DXUSAFE -DSAFETY -w -o pan pan.c
pan -m10000 -N live
spin -t resource_allocation.pml