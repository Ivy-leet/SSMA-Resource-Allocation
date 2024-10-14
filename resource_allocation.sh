#!bin/bash

echo $1

spin -a resource_allocation.pml
gcc -DMEMLIM=1024 -DVECTORSZ=2048 -O2 -DXUSAFE -w -o pan pan.c
./pan -m10000 -E -a -N $1

start_time="$(date + "%s")"

spin -t resource_allocation.pml

# End time
# end=$(date + %s.%N)

# Calculate execution time in seconds
# dur=$(echo "$(date +%s.%N) - $start")

# printf "Execution time: %.6f seconds\n" $dur

# End time
end_time="$(date + "%s")"

# Calculate the execution time using awk
execution_time=$(echo | awk -v start=$start_time -v end=$end_time '{print end - start}')

# Output the result
printf "Execution time: %.6f seconds\n" $execution_time

exit 0
