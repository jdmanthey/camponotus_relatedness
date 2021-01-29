#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=filter
#SBATCH --nodes=1 --ntasks=1
#SBATCH --partition quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-45

# define input files from helper file during genotyping
input_array=$( head -n${SLURM_ARRAY_TASK_ID} helper6.txt | tail -n1 )

# define main working directory
workdir=/lustre/scratch/jmanthey/04_relatedness_test

# run vcftools with SNP output spaced 100kbp
vcftools --vcf ${workdir}/03_vcf/${input_array}.g.vcf --max-missing 1.0 --minQ 20 --minGQ 20 --minDP 8 --max-meanDP 50 --min-alleles 2 --max-alleles 2 --mac 1 --thin 100000 --max-maf 0.49 --remove-indels --recode --recode-INFO-all --out ${workdir}/04_filtered_vcf_100kbp/${input_array}

# run vcftools with SNP output spaced 50kbp
vcftools --vcf ${workdir}/03_vcf/${input_array}.g.vcf --max-missing 1.0 --minQ 20 --minGQ 20 --minDP 8 --max-meanDP 50 --min-alleles 2 --max-alleles 2 --mac 1 --thin 50000 --max-maf 0.49 --remove-indels --recode --recode-INFO-all --out ${workdir}/05_filtered_vcf_50kbp/${input_array}

# run bcftools to simplify the vcftools output for the 50kbp spacing
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%GT]\n ' ${workdir}/05_filtered_vcf_50kbp/${input_array}.recode.vcf > ${workdir}/05_filtered_vcf_50kbp/${input_array}.simple.vcf

# run bcftools to simplify the vcftools output for the 100kbp spacing
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%GT]\n ' ${workdir}/04_filtered_vcf_10kbp/${input_array}.recode.vcf > ${workdir}/04_filtered_vcf_100kbp/${input_array}.simple.vcf

