
DIR="${1}" #directory of the CAND file (ex. 2020-11-09:....all.cand)
CAND="${2}" 
FILE="${3}" #.fil file with its path

#write candidates above an snr of 10 and in the DM range 330 - 370 with more than 100 points of distribution out into the FRBcand.txt
cat $CAND | awk '($6 >= 330)&&($6 <= 370)&&($1 > 6)&&($7 >= 5)' > FRBcand.txt

#write the 1st (snr), 3rd (time), 11th (one's as samp_idx), 6th (DM), 4th (Boxcar Filter Number), and 10th (ones) into FRBcand_manual that will be fed into PlotCand.py
cat FRBcand.txt | awk '{printf("%s\t%s\t%s\t%s\t%s\t%s\n", $1, $3, $11, $6, $4, $10)}' > FRBcand_manual 

mkdir Plot
cd ./Plot
#Plot selected candidates in FRBcand_manual
python /home/vgajjar/PulsarSearch/PlotCand.py $FILE $DIR/FRBcand_manual
