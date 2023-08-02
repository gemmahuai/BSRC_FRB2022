#convert zapped time bins in the given txt file to a string in output.txt that could be input into rfifind -zapints (ex. 1:10,20,103,140:145,...)
#sh conv_zapints_rfifind.sh <input directory> <output directory> <.txt filename>


txt_loc="${1}"
out_loc="${2}"
filename="${3}"
cd $txt_loc/
t_s=0.00016384 # sample time in seconds (163.84 us)
duration=0.05 # by default, remove duration of 0.05 seconds.

rm rfifind_format.txt
# 1. read each row in .txt file 。
# 2. determine if a row contains one or two values。
# 3. convert time in seconds to channel number。
# 4. if 1 element in the row: add 0.05s (to channel number) and append a:b to an output file
#    if 2 elements in the row: append a:b to the output file
# 5. print everything in a row using awk...

# NoF=$(awk 'END {print NR}' $filename)
# echo $NoF

i=1
while read -r line;
do
   echo "$i"
   echo "$line" 
   if [ ${#line} -le 7 ]
   then 
   	echo "'$line'is a number"
		tbin_start=$( echo "$line/$t_s" | bc -l | cut -f1 -d".")
      #echo "$tbin_start"
      duration_bin=$( echo "$duration/$t_s" | bc -l | cut -f1 -d".")
      #echo "$duration_bin"
      tbin_end=$( echo $tbin_start + $duration_bin | bc)
      echo "$tbin_start:$tbin_end" >> rfifind_format.txt
   else 
   	echo "'$line' is an interval"
		time_start=$(awk 'NR=='$i' {print $1}' $filename)
      tbin_start=$( echo "$time_start/$t_s" | bc -l | cut -f1 -d".")
      time_end=$(awk 'NR=='$i' {print $2}' $filename)
      tbin_end=$( echo "$time_end/$t_s" | bc -l | cut -f1 -d".")
      #echo "$tbin_start"
      echo "$tbin_start:$tbin_end" >> rfifind_format.txt
   fi
i=$(($i+1))

done < $filename

echo "Done conversion"

awk  '{ printf( "%s ", $1 ); } END { printf( "\n" ); }' rfifind_format.txt | tr ' ' ',' > output.txt #print the first column into a row and save in a .txt file
rm rfifind_format.txt