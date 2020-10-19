checkm lineage_wf -t 12 -x fa ./ ./checkm_qa > bin_quality.log

#make GenomeInfo.csv
cat bin_quality.log | sed '3d' | sed 's/ *[a-z]__.*) *[0-9]* *[0-9]* *[0-9]* *[0-9]* *[0-9]* *[0-9] *[0-9]* *[0-9]* *[0-9]* */\.fa\t/g' | sed 's/ *[0-9]*\.[0-9]* *$//g' | sed 's/^ *//g' | sed 's/  * /\t/g' > bin_quality.txt
cat ../appendix bin_quality.txt > bin_quality.tsv
rm bin_quality.txt
#take a look to make sure no error

conda deactivate
dRep dereplicate ./drep  -p 32 -comp 50 -con 15 -g *.fa --genomeInfo bin_quality.tsv

for f in *.fa ; do java -jar UBCG.jar extract -i $f -bcg_dir rabludge/bcg -label ${f%.fa} -t 12; done
java -jar UBCG.jar align -bcg_dir rabludge/bcg -out_dir rabludge/tree -t 12 -prefix rabludge -raxml
java -jar OAU.jar -u usearch -fd oscillatoria/ -n 12 -o all_cyano/test2 -fmt matrix

prodigal -p meta -a rabludge.faa -d rabludge.fna -i dereplicated_all.fna

for f in *.fna; do prodigal -a aa/{f%.fna}.faa -d na/{f%.fna}.fna -i $f -p single;done

enrichm annotate --verbosity 5 --output enrichM/ --protein_directory dereplicated_genomes/aa --ko --ko_hmm --pfam --tigrfam --orthologs --threads 12 --parallel 12
