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

time Rscript rf_mc.R --args 2 &    #  2 cores in use
time Rscript rf_mc.R --args 4 &    #  6 cores in use
time Rscript rf_mc.R --args 8 &    # 14 cores in use
time Rscript rf_serial.R &         # 15 cores in use
time Rscript rf_mc.R --args 1      # 16 cores in use
time Rscript rf_mc.R --args 16
