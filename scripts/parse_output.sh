#!/bin/bash
TIME_INPUT=time.out
RENAISSANCE_INPUT=renaissance.csv
CSV_OUTPUT=renaissance-parsed.csv


cd "$(dirname "$0")"

# get process cpu and mem usage from time
CPUAVG=$(grep -oP '(?<=cpuavg )([0-9]+)(?=%)' $TIME_INPUT)
#CPU_UTIL=$(printf %.1f "$((10**1 * $CPUAVG / 100))e-1")
CPU_UTIL=$(echo "scale=1 ; $CPUAVG / 100" | bc)
RSSMAX=$(grep -oP '(?<=rssmax )([0-9\.]+)' $TIME_INPUT)
MEM_USED=$(($RSSMAX * 1024))

# get benchmark duration from renaissance
cat $RENAISSANCE_INPUT | while read line ; 
do 
TS=$(echo $line | cut -d',' -f4); 
uptime=$(echo $line | cut -d',' -f3) ; 
[ "$TS" = "vm_start_unix_ms" ] && echo $line,"cpu_used,mem_used,TS,component" && continue ; 
echo -n $line ; 
TS=$(date -d @$((($TS+($uptime/1000000))/1000)) "+%Y-%m-%d %H:%M:%S %Z") ; 
echo ",$CPU_UTIL,$MEM_USED,$TS,renaissance" ; 
done > $CSV_OUTPUT
