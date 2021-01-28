# if you are not already in an interactive session, start one and wait to be logged in to a compute node
interactive -c 1 -p quanah

# Move to your working directory and then to the 06_related_files directory
cd /lustre/scratch/jmanthey/04_relatedness_test/
cd 06_related_files

# concatenate the simple vcfs from the 10kbp spacing vcf directory to the current working directory
cat ../04_filtered_vcf_10kbp/*simple.vcf > filtered_10kbp.vcf

# concatenate the simple vcfs from the 50kbp spacing vcf directory to the current working directory
cat ../05_filtered_vcf_50kbp/*simple.vcf > filtered_50kbp.vcf

#########
#########
### copy the R file: vcf_to_related.r to your current working directory
#########
#########

# load and start R
module load R
R

# run the following R code to convert your files
source("vcf_to_related.r")
vcf_to_related("filtered_10kbp.vcf", "filtered_10kbp.related", "camp_popmap.txt")
vcf_to_related("filtered_50kbp.vcf", "filtered_50kbp.related", "camp_popmap.txt")

#########
#########
### copy the .related output files to your local computer for calculating relatedness
### you will also need the camp_popmap.txt file with these .related files
#########
#########
