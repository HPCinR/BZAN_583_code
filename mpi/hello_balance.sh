#!/bin/bash
#SBATCH --job-name utk
#SBATCH --account=bckj-delta-cpu
#SBATCH --partition=cpu
#SBATCH --mem=20g
#SBATCH --nodes=2
#SBATCH --cpus-per-task=6
#SBATCH --tasks-per-node=4
#SBATCH --time 00:10:00
#SBATCH -e ./utk.e
#SBATCH -o ./utk.o

pwd
module load r
module list

## mclapply gets 6 cores per rank
time mpirun -np 8 Rscript hello_balance.R
