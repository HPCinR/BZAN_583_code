#!/bin/bash
#SBATCH --job-name utk
#SBATCH --account=bckj-delta-cpu
#SBATCH --partition=cpu
#SBATCH --mem=20g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --time 00:10:00
#SBATCH -e ./utk.e
#SBATCH -o ./utk.o

pwd

module load r
echo "loaded R"

time Rscript rf_cv_serial.R
time Rscript rf_cv_mc.R --args 8
time Rscript rf_cv_mc.R --args 16
