# RAB_DON
Raw data and source code for reproducing the results in our paper
## Install dependencies
All the processes were performed on ubuntu 18.04LTS OS.
We recommond using [Anaconda](https://www.anaconda.com/) to install all the dependencies.   
At least 256GB RAM for completely finish the whole pipeline.
### Quality control
```
conda install -c bioconda fastqc trimmomatic
```
### 16S rRNA genes sequencing processing
Please follow the instructions [here](https://docs.qiime2.org/2020.6/install/) to install the amazing QIIME2 platform.  
Also, the insertion tree file and database (Green Gene and SILVA) have to be [downloaded](https://docs.qiime2.org/2020.6/data-resources/).
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
conda install -c bioconda enrichm hmmer diamond
```
### R packages
* DESeq2
* vegan
* tidyverse
* ggpubr
## Amplicon sequencing data processing
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
```