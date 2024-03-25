#!/bin/bash
#SBATCH --job-name utk
#SBATCH --account=bckj-delta-cpu
#SBATCH --partition=cpu
#SBATCH --tasks=1
#SBATCH --time 00:00:10
#SBATCH -e ./utk.e
#SBATCH -o ./utk.o

cd ~/BZAN_583_code
pwd

## module names can vary on different platforms
module load r
echo "loaded R"
module list

time Rscript profile.R
