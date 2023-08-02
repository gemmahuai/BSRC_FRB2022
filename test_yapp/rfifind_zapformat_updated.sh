#convert zapped time bins in the given txt file to a string in output.txt that could be input into rfifind -zapints (ex. 1:10,20,103,140:145,...)
# just discovered that these values must be integers
#sh conv_zapints_rfifind.sh <input directory> <output directory> <.txt filename>

txt_loc="${1}"
out_loc="${2}"
filename="${3}"
cd $txt_loc/
t_s=1.0 # sample time in seconds (163.84 us)
duration=1.0 # by default, remove duration of 1.0 seconds, must be an integer

rm rfifind_format.txt
rm output.txt
# 1. read each row in .txt file 。
# 2. determine if a row contains one or two values。
# 4. if 1 element in the row: add 0.05s and append a:b to an output file
#    if 2 elements in the row: append a:b to the output file
# 5. print everything in a row using awk...

# NoF=$(awk 'END {print NR}' $filename)
# echo $NoF

### 07/20/2023 update:
# 1. resolve 341:341 - if the second number == the first, then add 1s (only if there are 2 elements in the row)
# 2. resolve 341:342,341:341 - if both numbers in the second string == 1st string, then no append...

i=1
while read -r line;
do
   # echo "$i"
   # echo "$line" 
   if [ ${#line} -le 7 ]
   then 
    # echo "'$line'is a number"
	    tbin_start=$( echo "$line/$t_s" | bc -l | cut -f1 -d".")
      #echo "$tbin_start"
      duration_bin=$( echo "$duration/$t_s" | bc -l | cut -f1 -d".")
      #echo "$duration_bin"
      tbin_end=$( echo $tbin_start + $duration_bin | bc)
      echo "$tbin_start:$tbin_end" >> rfifind_format.txt
   else 
   	# echo "'$line' is an interval"
		time_start=$(awk 'NR=='$i' {print $1}' $filename)
      tbin_start=$( echo "$time_start/$t_s" | bc -l | cut -f1 -d".")
      time_end=$(awk 'NR=='$i' {print $2}' $filename)
      tbin_end=$( echo "$time_end/$t_s" | bc -l | cut -f1 -d".")
      #echo "$tbin_start"
      if [ $tbin_start -eq $tbin_end ]; then 
        # echo "REPEAT"
        tbin_end=$( echo $tbin_start + $duration_bin | bc)
        echo "$tbin_start:$tbin_end" >> rfifind_format.txt
      else 
        echo "$tbin_start:$tbin_end" >> rfifind_format.txt
      fi 
   fi
i=$(($i+1))

done < $filename

echo "Done conversion"

sort rfifind_format.txt | uniq > output.txt

awk  '{ printf( "%s ", $1 ); } END { printf( "\n" ); }' output.txt | tr ' ' ','  #print the first column into a row, which can be directly read by rfifind -zapints
rm rfifind_format.txt