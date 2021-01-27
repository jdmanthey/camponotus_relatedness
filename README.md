## camponotus_relatedness

### Pipeline to use whole-genome sequencing data to estimate within-colony relatedness for several camponotus species

### Steps to run:
    1. Perform all steps in 01_setup.sh interactively.
    2. Modify the 02_trim_align.sh script as necessary for your directory and submit the script for running.
    3. Run an interactive job on the cluster.
        a. Move to your main working directory
        b. Load the module for R (module load R) and start R (R)
        c. Run the commands in 03_create_genotype_scripts.r
        d. This creates three nested directories of scripts (11_genotype_scripts) to run in three steps.
    4. Run shell script in 11_genotype_scripts/01_gatk_split
        f. Once step e finishes, run the shell script in 11_genotype_scripts/02b_gatk_database
        g. Once step f finishes, run the shell script in 11_genotype_scripts/03b_group_genotype_database
    5. 

### Notes
    1. The cluster just updated to SLURM, so most of the submission scripts are modified from previous projects using SGE.
    2. To submit a shell script: sbatch <filename>
    3. To check the jobs queue: squeue -u <username>
    4. To cancel a job: scancel <jobid>
