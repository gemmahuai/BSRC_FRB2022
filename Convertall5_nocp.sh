#Band5
#sh batchwork_test.sh <.dat .hdr file directory> <output directory>

dat_loc="${1}"
out_loc="${2}"
cd $dat_loc/
#ls *.hdr | grep FRB > $out_loc/filename_hdr.txt 
ls *.hdr > $out_loc/filename_hdr.txt
cd $out_loc/
#ls $dat_loc/*.hdr | grep FRB > ./filename_hdr.txt
filenamehdr_loc=filename_hdr.txt

# total number of rows in the filename.txt (number of files in a directory)
NoF=$(awk 'END {print NR}' $filenamehdr_loc)
echo $NoF
sed -e 's!.hdr!!' $filenamehdr_loc > filename.txt

FILENAME=filename.txt
LINES=$(cat $FILENAME)

i=1
for LINE in $LINES
do
	echo "$i/$NoF"
#Convert to MDJ
	echo "Start to convert to mjd time"
	#> nohup.out #append all outputs
	F1=`echo $LINE`
	echo $F1
	DATFILE=`echo $dat_loc/$LINE`
	FILE=`echo $dat_loc/$LINE.hdr`
	FILFILE=`echo $out_loc/$F1.fil`
	h=`sed -n 2p $FILE | awk -F: '{print$2}'`
	m=`sed -n 2p $FILE | awk -F: '{print$3}'`
	s=`sed -n 2p $FILE | awk -F: '{print$4}'`
	d=`sed -n 3p $FILE | awk -F: '{print$2}'`
	mt=`sed -n 3p $FILE | awk -F: '{print$3}'`
	y=`sed -n 3p $FILE | awk -F: '{print$4}'`
	mjd=`cal2mjd $y $mt $d $h $m $s | awk -F"is" '{print$2}'`
	echo "mjd = $mjd"

#Convert raw data to filterbank format
	echo "Start to convert to filterbank format"
	#cmd="/home/vgajjar/sigproc_for_gmrt/sigproc-3.7/filterbank $DATFILE -rf 500.0 -ts 0.00008192 -bw -0.09765625 -nch 2048 -mjd $mjd -n 16 -o $FILFILE -df gmgwbr"
	cmd="/home/vgajjar/sigproc_for_gmrt/sigproc-3.7/filterbank $DATFILE -rf 1460.0 -ts 0.00016384 -bw -0.09765625 -nch 2048 -mjd $mjd -n 16 -o $FILFILE -df gmgwbr"
	echo $cmd
	eval $cmd

#Pulsar searching with SP_search_uGMRT.py
	#echo "Start to search for pulsars with SP_search_uGMRT.py"
	#cmd="SP_search_uGMRT.py --fil $FILFILE --dorfi --lodm 330 --hidm 370 --maxCsec=4 --filter_cut=16 --boxcar_max=2048 --heimdall "-dm_tol 1.05""
	#echo $cmd
	#eval $cmd
	i=$(($i+1))
	echo "Done"
done

#rm *.txt
