#!/bin/bash
tmpDIRname=SLIPID_450mM_OPtmp
mkdir $tmpDIRname
cd $tmpDIRname
cp ../calcORDPslipid.sh ./
cp ../gro_OP.awk ./
trajname=/m/nbe/work/ollilas1/POPCdata/POPCslipids/450mMCaCl/md_last100ns.xtc
tprname=/m/nbe/work/ollilas1/POPCdata/POPCslipids/450mMCaCl/md.tpr
numberOFlipids=200
outFILE=../../Data/POPC/CaCl/SLIPID/450mM/OrderParameters.dat
#Calculate order parameter for each lipid separately
echo 'keep 2
splitres 0
q
' | make_ndx -f $tprname
for((  j = 1 ;  j <= $numberOFlipids;  j=j+1  ))
do
    rm runPROT.gro
    echo "$j" | trjconv -f $trajname -s $tprname -o runPROT.gro -n index.ndx -pbc res
    sh calcORDPslipid.sh > OrderParameters_"$j".dat
done
#Calculate average and the error of the mean of order parameters over lipids.
echo '0
0
0
0
0
0
0
0
0' > OrderParametersSUM.dat
echo '0
0
0
0
0
0
0
0
0' > OrderParametersSDsum.dat
for((  j = 1 ;  j <= $numberOFlipids;  j=j+1  ))
do
    paste OrderParametersSUM.dat OrderParameters_"$j".dat | awk '{print $1+$2}' > tmp.dat
    mv tmp.dat OrderParametersSUM.dat
    sum=$(($sum+1))
done
cat OrderParametersSUM.dat | awk -v sum=$sum '{print $1/sum}' > OrderParametersAV.dat
sum=0
for((  j = 1 ;  j <= $numberOFlipids;  j=j+1  ))
do
    paste OrderParametersAV.dat OrderParameters_"$j".dat OrderParametersSDsum.dat | awk '{print $3+($1-$2)*($1-$2)}' > tmp.dat
    mv tmp.dat OrderParametersSDsum.dat
    sum=$(($sum+1))
done
paste OrderParametersAV.dat OrderParametersSDsum.dat | awk -v sum=$sum '{print $1" "sqrt($2/sum)/sqrt(sum)}' > $outFILE
cd ..
rm $tmpDIRname/*
rmdir $tmpDIRname
