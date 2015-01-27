#!/bin/bash

MAX_PACKS=1000000

echo "Compilando..."
make all
echo "Done"

echo nop > /sys/kernel/debug/tracing/current_tracer
echo 0 > /sys/kernel/debug/tracing/tracing_on
echo function_graph > /sys/kernel/debug/tracing/current_tracer

num_sockets=1
num_threads=1
num_clients=4
./server $MAX_PACKS $num_threads $num_sockets &
pid=$!
sleep 1
for ((i=1 ; $i<=$num_clients ; i++))
{
	./client $(($MAX_PACKS*10)) $num_sockets 127.0.0.1 > /dev/null &
}
wait $pid

make clean

cat /sys/kernel/debug/tracing/trace > "Trace_"$num_sockets"Sockets_"$num_threads"Threads_"$num_clients"Clients.txt"

echo "Done"