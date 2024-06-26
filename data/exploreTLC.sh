#!/bin/bash
#SBATCH --job-name utk
#SBATCH --account=bckj-delta-cpu
#SBATCH --partition=cpu
#SBATCH --mem=60g
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --time 00:10:00
#SBATCH -e ./utk.e
#SBATCH -o ./utk.o

pwd

module load r
echo "loaded R"
module list

time Rscript exploreTLC.R
