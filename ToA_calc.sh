
### Calculate the expected time of arrival of each Band 3 burst at Band 5 and extract data for each from Band 5. ###
### Usage: sh ToA_all.sh <.txt> ###
### TXT: 1st_col = directory of band 5 FIL file
###      2nd_col = FIL file name
###      3rd_col = DM
###      4th_col = time of arrival in second
###      5th_col = time of arrival in MJD

FILENAME="${1}"

NR=$(awk 'END {print NR}' $FILENAME)
#LINES=$(awk 'FNR == 1 {print $1}' $FILENAME)

i=1
while [ $i -le $NR ]
do
    cd /datax/scratch/zghuai/uGMRT_FRB/
    DIR=$(awk -v j=$i 'FNR == j {print $1}' $FILENAME)
    file=$(awk -v j=$i 'FNR == j {print $2}' $FILENAME)
    DM=$(awk -v j=$i 'FNR == j {print $3}' $FILENAME)
    ToA_s=$(awk -v j=$i 'FNR == j {print $4}' $FILENAME)
    ToA_mjd=$(awk -v j=$i 'FNR == j {print $5}' $FILENAME)
    cd $DIR
    cp /datax/scratch/zghuai/uGMRT_FRB/ToA_calc.py ./
    python ToA_calc.py $file $ToA_s $ToA_mjd 1460 500 $DM >> toa_b5.txt #append the new toa to a text file
    toa_b5=$(tail -n 1 toa_b5.txt) # print the last row in the text file
    if [ $toa_b5 -eq 0 ]
    then 
        echo "Out of length, please visit the previous FIL file. $DIR/$file"
        # mark this out in the toa_b5.txt file (the same line) ???
    else 
        toa_b5=`echo $toa_b5-0.5 | bc` # 0.5s earlier than the expected arrival time just in case.
        # extract
        Dir="extract"
        if [ -d "$Dir" ]
        then
        ### directly extract data if the extract directory exists ###
            cmd="dspsr -N test -S $toa_b5 -c 10 -T 10 -D $DM -O ./extract/extract_$toa_b5 $file"
            echo $cmd
            eval $cmd
        else
        ### create a new directory, extract, and then extract data
            mkdir extract
            cmd="dspsr -N test -S $toa_b5 -c 10 -T 10 -D $DM -O ./extract/extract_$toa_b5 $file"
            echo $cmd
            eval $cmd
        fi  

    fi
    echo "$i/$NR Done"
    i=$(($i+1))
done
