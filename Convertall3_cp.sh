
#Band3 copy + conversion

#sh batchwork_test.sh <.dat .hdr file directory> <output directory>

dat_loc="${1}"
out_loc="${2}"

ls $dat_loc/*.hdr > $out_loc/filename_h.txt

cd $out_loc/
i=1
#ls $dat_loc/*.hdr | grep FRB > ./filename_hdr.txt
filenamehdr=filename_h.txt
NoF=$(awk 'END {print NR}' $filenamehdr)
echo $NoF
hdrs=$(cat $filenamehdr)
for hdr in $hdrs
do
	echo "$i/$NoF"
	echo $hdr
	datfile=`echo $hdr | sed -e 's!.hdr!!'`
	echo $datfile
	cp $hdr $out_loc #copy .hdr file to the output directory
	cp $datfile $out_loc #copy .dat file to the output directory
	
	# store the .dat & .hdr name only into two variables
	dat_i=$(ls $out_loc | grep hdr | sed -e 's!.hdr!!')
	hdr_i=$(ls $out_loc | grep hdr)

	echo "Start to convert to mjd time"
        #> nohup.out #append all outputs
        fil_i=`echo $dat_i.fil`
        h=`sed -n 2p $hdr_i | awk -F: '{print$2}'`
        m=`sed -n 2p $hdr_i | awk -F: '{print$3}'`
        s=`sed -n 2p $hdr_i | awk -F: '{print$4}'`
        d=`sed -n 3p $hdr_i | awk -F: '{print$2}'`
        mt=`sed -n 3p $hdr_i | awk -F: '{print$3}'`
        y=`sed -n 3p $hdr_i | awk -F: '{print$4}'`
        mjd=`cal2mjd $y $mt $d $h $m $s | awk -F"is" '{print$2}'`
        echo "mjd = $mjd"

	#convert
	echo "Start to convert to filterbank format"
        cmd="/home/vgajjar/sigproc_for_gmrt/sigproc-3.7/filterbank $dat_i -rf 500.0 -ts 0.00008192 -bw -0.09765625 -nch 2048 -mjd $mjd -n 16 -o $fil_i -df gmgwbr"
        echo $cmd
        eval $cmd
	echo "Done"

	#Remove .dat .hdr
	rm $dat_i
	rm *.hdr

	i=$(($i+1))
 
done





# total number of rows in the filename.txt (number of files in a directory)
#NoF=$(awk 'END {print NR}' $filenamehdr_loc)
#echo $NoF
#sed -e 's!.hdr!!' $filenamehdr_loc > filename.txt

#FILENAME=filename.txt
#LINES=$(cat $FILENAME)

#i=1
#for LINE in $LINES
#do
#        echo "$i/$NoF"
#Convert to MDJ
#        echo "Start to convert to mjd time"
#        #> nohup.out #append all outputs
#        F1=`echo $LINE`
#        echo $F1
#        DATFILE=`echo $dat_loc/$LINE`
#        FILE=`echo $dat_loc/$LINE.hdr`
#        FILFILE=`echo $out_loc/$F1.fil`
#        h=`sed -n 2p $FILE | awk -F: '{print$2}'`
#        m=`sed -n 2p $FILE | awk -F: '{print$3}'`
#        s=`sed -n 2p $FILE | awk -F: '{print$4}'`
        #d=`sed -n 3p $FILE | awk -F: '{print$2}'`
        #mt=`sed -n 3p $FILE | awk -F: '{print$3}'`
       # y=`sed -n 3p $FILE | awk -F: '{print$4}'`
      #  mjd=`cal2mjd $y $mt $d $h $m $s | awk -F"is" '{print$2}'`
     #   echo "mjd = $mjd"

#Convert raw data to filterbank format
    #    echo "Start to convert to filterbank format"
   #     cmd="/home/vgajjar/sigproc_for_gmrt/sigproc-3.7/filterbank $DATFILE -rf 500.0 -ts 0.00008192 -bw -0.09765625 -nch 2048 -mjd $mjd -n 16 -o $FILFILE -df gmgwbr"
  #      echo $cmd
 #       eval $cmd

#        i=$(($i+1))
#        echo "Done"
#done
