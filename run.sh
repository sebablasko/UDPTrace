#!/bin/bash
#Se requiere la variable res_dir
res_dir=../RESULTS
#Recuperar parametros
packages=$1
shift 1
repetitions=$1
shift 1
threads=$@

echo "Compilando..."
make all
echo "Done"

mkdir perf
echo "Ejecutando Prueba..."
for num_threads in $threads
do
	echo "Evaluando "$num_threads" Threads"
	linea="$num_threads,";
	for ((i=1 ; $i<=$repetitions ; i++))
	{
		perf record -- ./server $packages $num_threads > aux &
		#./server $num_threads 1 > aux &
		pid=$!
		sleep 1
		./client $packages 127.0.0.1 > /dev/null &
		./client $packages 127.0.0.1 > /dev/null &
		./client $packages 127.0.0.1 > /dev/null &
		./client $packages 127.0.0.1 > /dev/null &
		sleep 1
		wait $pid
		#wait $pid2
		#wait $pid3
		#wait $pid4
		#wait $pid5
		linea="$linea$(cat aux)"
		rm aux
		perf_file="perf/{"$num_threads"}perf_"$i".data"
		output_perf_file="perf/{"$num_threads"}perf_"$i".txt"
		perf report > $output_perf_file
		mv perf.data $perf_file
	}
	output_csv_file=$res_dir"/UDP_times.csv"
	echo "$linea" >> $output_csv_file
done
make clean
echo "Done"