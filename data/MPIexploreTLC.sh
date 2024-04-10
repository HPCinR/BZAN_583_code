#!/bin/bash
#SBATCH --job-name utk
#SBATCH --account=bckj-delta-cpu
#SBATCH --partition=cpu
#SBATCH --mem=150g
#SBATCH --nodes=1
#SBATCH --tasks-per-node 6
#SBATCH --cpus-per-task=1
#SBATCH --time 01:00:00
#SBATCH -e ./utk.e
#SBATCH -o ./utk.o

pwd

module load r
echo "loaded R"
module list

time mpirun -np 6 Rscript MPIexploreTLC.R
