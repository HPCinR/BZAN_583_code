#!/bin/bash
#SBATCH --job-name utk
#SBATCH --account=bckj-delta-cpu
#SBATCH --partition=cpu
#SBATCH --mem=16g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time 00:00:30
#SBATCH -e ./utk.e
#SBATCH -o ./utk.o

pwd

## module names can vary on different platforms
module load r
echo "loaded R"
module list

time Rscript TLC_explore.R
