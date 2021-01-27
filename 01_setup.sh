# start an interactive session and wait to be logged in to a compute node
interactive -c 1 -p quanah

# move to your working directory for this project
cd /lustre/scratch/jmanthey/04_relatedness_test/

# make directories for organization during analyses
mkdir 00_fastq
mkdir 01_cleaned
mkdir 01_mtDNA
mkdir 01_bam_files
mkdir 02_vcf
mkdir 03_vcf
mkdir 04_filtered_vcf
mkdir 05_related_files

#####################################
#####################################
#####################################
##### transfer your raw data files for this project to the directory 00_fastq
#####################################
#####################################
#####################################

#####################################
#####################################
#####################################
##### make a file map in the style of the file "rename_samples.txt" for your samples
##### and put it in your 00_fastq directory
#####################################
#####################################
#####################################

# move to the fastq directory
cd /lustre/scratch/jmanthey/04_relatedness_test/00_fastq/

# rename the files in a numbered fashion
while read -r name1 name2; do
	mv $name1 $name2
done < rename_samples.txt







