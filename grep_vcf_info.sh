
#1.GREP CONTIG INFO FROM VCF FILE

#unzip all vcf files
gunzip -d G*.vcf.gz

#Get the contig ids and length from vcf files
for i in {1..3}
do
  grep '##contig' G$i.*.vcf| cut -f3 -d=|cut -f1 -d, > temp.id
  grep '##contig' G$i.*.vcf|cut -f4 -d=|cut -f1 -d'>' > temp.length
  paste temp.id temp.length > G$i.id_length.txt
done

rm temp*

#2.CREATE 012 FILES
#used to count number of snps per contig/scaffold
for i in {1..3}
do
  vcftools --vcf G$i.*.vcf  --012 --out  G$i.modern_variants
done


#3.CALCULATE number of snps per contig and per species 

#NOTE:THE LOOP TAKES A WHILE TO RUN. BEST TO RUN ON A CLUSTER IN AN ARRAY JOB (remove loop and replace $i by $PBS_ARRAYID)

for i in {1..3}
do

  #count number of contigs per species (for j loop)
  nb_id=$(wc -l G$i.id_length.txt| cut -d ' ' -f1)

  for (( j=1; j<=$nb_id; j++ ))
  do
    #read contig id (per line)
    id=$(sed -n $j"p" G$i.id_length.txt|cut -d$'\t' -f1)

    #count number of snps per contig (read 012.pos file , count rows with column 1=id, print firt column of wc)
    awk -v var=$id '$1 == var { print $0 }' G$i.modern_variants.012.pos| wc -l |cut -d ' ' -f1 >> G$i.n_snps
  done

  #final file with contig label,length and number of snps
  paste G$i.id_length.txt G$i.n_snps > G$i.seqinfo
done
