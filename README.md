## camponotus_relatedness

# Pipeline to use whole-genome sequencing data to estimate within-colony relatedness for several camponotus species

# Steps to run:
    1. Perform all steps in 01_setup.sh interactively.
    2. Modify the 02_trim_align.sh script as necessary for your directory and submit the script for running.
    3. 

# Notes
    1. The cluster just updated to SLURM, so most of the submission scripts are modified.
    2. To submit a shell script: sbatch <filename>
    3. To check the jobs queue: squeue -u <username>
    4. To cancel a job: scancel <jobid>
