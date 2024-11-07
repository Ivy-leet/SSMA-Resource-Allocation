#!bin/bash

echo $1

spin -a resource_allocation.pml
gcc -DMEMLIM=1024 -DVECTORSZ=2048 -O2 -DXUSAFE -w -o pan pan.c
./pan -m10000 -a -N $1

spin -t resource_allocation.pml
