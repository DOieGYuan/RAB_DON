# RAB_DON
Raw data and source code for reproducing the results in our paper
## Data
Raw 16S rRNA genes and shotgun sequencing reads are deposited in NCBI SRA: [download]().  
Metagenomic-assembled genomes are available in [MAGs](https://github.com/DOieGYuan/RAB_DON/tree/master/MAGs).  

**We welcome readers to reproduce the results in our paper and the following are the core Bioinformatics steps in this work:**  
*PS: Additional codes not list are available in [AdditionalCode](https://github.com/DOieGYuan/RAB_DON/tree/master/AdditionalCodes)*  

## Dependencies
All the processes were performed on ubuntu 18.04LTS OS.  
We recommond using [Anaconda](https://www.anaconda.com/) to install all the dependencies.   
At least 256GB RAM for the whole pipeline.
### Quality control
```
conda install -c bioconda fastqc trimmomatic
```
### 16S rRNA genes sequencing processing
Please follow the instructions [here](https://docs.qiime2.org/2020.6/install/) to install the amazing QIIME2 platform.  
Also, the insertion tree file and databases (i.e., Green Gene and SILVA databases) have to be [downloaded](https://docs.qiime2.org/2020.6/data-resources/).  
### Assembly
```
conda install -c bioconda spades quast
```
### Binning
```
conda install -c bioconda metabat2 maxbin2 concoct checkm-genome bowtie2 drep
```
install [metaWRAP](https://github.com/bxlab/metaWRAP)

>conda create -n metawrap python=2.7  
>conda activate metawrap  
>conda config --add channels defaults  
>conda config --add channels conda-forge  
>conda config --add channels bioconda  
>conda config --add channels ursky  
>conda install --only-deps -c ursky metawrap-mg  

### Taxonomic classification
```
conda install -c bioconda gtdbtk
```
### Functional annotation
```
conda install -c bioconda enrichm hmmer diamond blast
```
### R packages
* DESeq2
* vegan
* tidyverse
* ggpubr
* agricolae

## Amplicon sequencing data processing
First import all the reads in fastq into qiime2-readable .qza files using [manifest.AB.txt]() and [manifest.NS.txt]().  
Remember to change the **absolute-path** to the directory with all fastq files in your own system.  
The following codes are the example used in our study.
```
# Import fastq as qza
qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \
--input-path manifest.txt \
--output-path test.qza \
--input-format PairedEndFastqManifestPhred33V2

# QC
qiime demux summarize --i-data all.qza --o-visualization all.qc.qzv
qiime tools view all.qc.qzv

qiime dada2 denoise-paired \
--i-demultiplexed-seqs all.qza \
--p-trunc-len-f 220 \
--p-trunc-len-r 220 \
--p-n-threads 64 \
--o-table dada2_table.qza \
--o-representative-sequences dada2_rep_set.qza \
--o-denoising-stats stats.dada2.qza

# feature table summaries
qiime feature-table summarize \
  --i-table dada2_table.qza \
  --o-visualization dada2_table.qzv \
  --m-sample-metadata-file metadata.tsv
qiime tools view dada2_table.qzv

qiime feature-table tabulate-seqs \
  --i-data dada2_rep_set.qza \
  --o-visualization dada2_rep_set.qzv
qiime tools view dada2_rep_set.qzv

# Generate a tree for phylogenetic diversity analyses
qiime fragment-insertion sepp \
  --i-representative-sequences dada2_rep_set.qza \
  --i-reference-database sepp-refs-gg-13-8.qza \
  --o-tree tree.qza \
  --o-placements tree_placements.qza \
  --p-threads 64

# Alpha Rarefaction and Selecting a Rarefaction Depth  
  qiime diversity alpha-rarefaction \
  --i-table dada2_table.qza \
  --i-phylogeny tree.qza \
  --m-metadata-file metadata.tsv \
  --p-metrics observed_otus shannon faith_pd chao1 \
  --o-visualization alpha_rarefaction_curves.qzv \
  --p-min-depth 25 \
  --p-steps 20 \
  --p-max-depth 15000
qiime tools view alpha_rarefaction_curves.qzv

# Diversity analysis
qiime diversity core-metrics-phylogenetic \
  --i-table dada2_table.qza \
  --i-phylogeny tree.qza \
  --m-metadata-file metadata.tsv \
  --p-sampling-depth 15000 \
  --p-n-jobs 12 \
  --output-dir ./core-metrics-results

  qiime tools view core-metrics-results/weighted_unifrac_emperor.qzv

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata.tsv \
  --m-metadata-column type \
  --p-method permanova \
  --o-visualization core-metrics-results/weighted-unifrac-type-permanova-significance.qzv
qiime tools view core-metrics-results/weighted-unifrac-type-permanova-significance.qzv

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata.tsv \
  --m-metadata-column source \
  --p-method permanova \
  --o-visualization core-metrics-results/weighted-unifrac-source-permanova-significance.qzv
qiime tools view core-metrics-results/weighted-unifrac-source-permanova-significance.qzv

qiime diversity adonis \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization core-metrics-results/weighted_adonis.qzv \
  --p-formula type+source
qiime tools view core-metrics-results/weighted_adonis.qzv

# Taxonomic classification
qiime feature-classifier classify-sklearn \
  --i-reads dada2_rep_set.qza \
  --i-classifier classifier.qza \
  --o-classification taxonomy_pretrained.qza
qiime taxa barplot \
  --i-table dada2_table.qza \
  --i-taxonomy taxonomy_pretrained.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization taxa_pretrained_barplot.qzv
qiime tools view taxa_pretrained_barplot.qzv
```
Export all the .tsv files when visulization. Or, skip this step by just downloading from [here].  
Use plot_alpha_diversity.R, plot_beta_diversity.R and plot_taxonomy.R to plot Figure 3a, 3b and 3c, respectively.  

## Shotgun sequencing data processing
### Quality control
Please refer to [QC section](https://github.com/DOieGYuan/DPRS_with_HMs#quality-control-1) in our previous work.
### Assembly
```
zcat AB1_?_1.fq.gz > AB1_1.fastq
zcat AB1_?_2.fq.gz > AB1_2.fastq
zcat AB2_?_1.fq.gz > AB2_1.fastq
zcat AB2_?_2.fq.gz > AB2_2.fastq
zcat AS_?_1.fq.gz > AS_1.fastq
zcat AS_?_2.fq.gz > AS_2.fastq
spades.py -o ./spades_assembly AB1 --meta -1 AB1_1.fastq -2	AB1_2.fastq	-t 32 -m 1000
spades.py	-o ./spades_assembly_AB2 --meta -1 AB2_1.fastq -2 AB2_2.fastq	-t 32 -m 1000
spades.py	-o ./spades_assembly_AS --meta -1 AS_1.fastq -2 AS_2.fastq -t 32 -m 1000
```
### Binning
```
./binning_wf.sh ./spades_assembly_AB1
./binning_wf.sh ./spades_assembly_AB2
./binning_wf.sh ./spades_assembly_AS
```
