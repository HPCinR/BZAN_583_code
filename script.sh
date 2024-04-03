#!/bin/bash
#SBATCH --job-name utk
#SBATCH --account=bckj-delta-cpu
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --mem=16g
#SBATCH --cpus-per-task=1
#SBATCH --time 00:00:30
#SBATCH -e ./utk.e
#SBATCH -o ./utk.o

module load r
Rscript hello.R