
#Band5 copy + conversion

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
	rawfile=`echo $hdr | sed -e 's!.hdr!!'`
	echo $rawfile
	cp $hdr $out_loc #copy .hdr file to the output directory
	cp $rawfile $out_loc #copy .dat file to the output directory
	
	# store the .dat & .hdr name only into two variables
	raw_i=$(ls $out_loc | grep hdr | sed -e 's!.hdr!!')
	hdr_i=$(ls $out_loc | grep hdr)

	echo "Start to convert to mjd time"
        #> nohup.out #append all outputs
        fil_i=`echo $raw_i.fil`
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
        cmd="/home/vgajjar/sigproc_for_gmrt/sigproc-3.7/filterbank $raw_i -rf 1460.0 -ts 0.00016384 -bw -0.09765625 -nch 2048 -mjd $mjd -n 16 -o $fil_i -df gmgwbr"
        echo $cmd
        eval $cmd
	echo "Done"

	#Remove .dat .hdr
	rm $raw_i
	rm *.hdr

	i=$(($i+1))
 
done



