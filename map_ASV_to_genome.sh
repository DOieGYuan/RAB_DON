#source script [output_dir]
test -e ${1%}||mkdir ${1%}
read -p "e-value: " evalue
read -p "identity: " identity

for f in *.fa;
do blastn -num_threads 12 -db blastndb/ASV -outfmt "6 sseqid evalue pident nident length" -query $f -evalue $evalue -perc_identity $identity -subject_besthit > /dev/shm/${f%.fa}.txt
test -s /dev/shm/${f%.fa}.txt && cat blastndb/title /dev/shm/${f%.fa}.txt > ${1%}/${f%.fa}.txt
done
