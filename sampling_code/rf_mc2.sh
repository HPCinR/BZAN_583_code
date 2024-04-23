#!/bin/bash
#SBATCH --job-name utk
#SBATCH --account=bckj-delta-cpu
#SBATCH --partition=cpu
#SBATCH --mem=20g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --time 00:10:00
#SBATCH -e ./utk2.e
#SBATCH -o ./utk2.o

pwd

module load r
module list

## Order the runs for faster total time
date
time Rscript rf_mc.R --args 2 &
time Rscript rf_mc.R --args 4 &
time Rscript rf_mc.R --args 8 &
time Rscript rf_serial.R &
time Rscript rf_mc.R --args 1
time Rscript rf_mc.R --args 16
date
