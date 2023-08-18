#convert zapped time bins in the given txt file to a string in output.txt that could be input into rfifind -zapints (ex. 1:10,20,103,140:145,...)
#converted to time intervals that match with the rfifind setting...
# example use: sh rfifind_zap_updated <input directory> <input text filename> <output directory> <.fil filename> <integer>
# sh rfifind_zap_updated ./ zap_timebins_fil.txt ./ B0138+59_bm4_pa_1460_200_16_30jan2021.raw.fil 4

### 08/17/2023 update:
# convert time (s) to time intervals. mapping relation: 1 interval  = 0.00032768*4800 s = 1.572864 s; or time per subint * 4 (after decimating by 2: time per subint * 2)
# t_conv=1.57286 #0.000016384*2 * 4800 # seconds per interval

txt_loc="${1}"
txtfile="${2}"
out_loc="${3}"
filfile="${4}"
N="${5}" # an integer (will be used to multiply with time per subint to obtain #seconds per interval) # usually this is 4.
cd $txt_loc/
t_s=1.0 # sample time in seconds (163.84 us)
duration=1. # by default, duration of 1 interval

rm rfifind_format.txt
rm output.txt
rm test.txt

readfile $filfile > test.txt
dataLine=29
tsubint=$(awk -v dataLine="$dataLine" 'NR==dataLine{print $6}' test.txt) # read the time per subint
intv=$( echo "$tsubint*$N" | bc -l)
echo $intv # time per interval set by rfifind
rm test.txt

i=1
while read -r line;
do
   #echo "$i"
   #echo "$line" 
   if [ ${#line} -le 7 ]
   then 
    #echo "'$line'is a number"
	   tint_start=$( echo "$line/$intv" | bc -l | cut -f1 -d".")
      #echo "$tint_start"
      tint_end=$( echo $tint_start + $duration | bc | cut -f1 -d".")
      #echo "$tint_end"
      echo "$tint_start:$tint_end" >> rfifind_format.txt
   else 
   	#echo "'$line' is an interval"
		time_start=$(awk 'NR=='$i' {print $1}' $txtfile)
      tint_start=$( echo "$time_start/$intv" | bc -l | cut -f1 -d".")
      time_end=$(awk 'NR=='$i' {print $2}' $txtfile)
      tint_end=$( echo "$time_end/$intv" | bc -l | cut -f1 -d".")
      tint_end=$( echo "$tint_end+1" | bc -l)
      #echo "$tbin_start"
      if [ $tint_start -eq $tint_end ]; then 
        # echo "REPEAT"
        tbin_end=$( echo $tint_start + $duration | bc | cut -f1 -d".")
        echo "$tint_start:$tint_end" >> rfifind_format.txt
      else 
        echo "$tint_start:$tint_end" >> rfifind_format.txt
      fi 
   fi
i=$(($i+1))

done < $txtfile

echo "Done conversion"

sort rfifind_format.txt | uniq > output.txt

awk  '{ printf( "%s ", $1 ); } END { printf( "\n" ); }' output.txt | tr ' ' ','  #print the first column into a row, which can be directly read by rfifind -zapints
rm rfifind_format.txt