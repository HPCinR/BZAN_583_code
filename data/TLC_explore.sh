#!/bin/bash
#SBATCH --job-name utk
#SBATCH --account=bckj-delta-cpu
#SBATCH --partition=cpu
#SBATCH --mem=40g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --time 00:15:00
#SBATCH -e ./utk.e
#SBATCH -o ./utk.o

pwd

module load r
echo "loaded R"
module list

time Rscript TLC_explore.R
