#!/bin/bash
#SBATCH --job-name utk
#SBATCH --account=bckj-delta-cpu
#SBATCH --partition=cpu
#SBATCH --mem=128g
#SBATCH --nodes=2
#SBATCH --cpus-per-task=8
#SBATCH --tasks-per-node=4
#SBATCH --time 00:20:00
#SBATCH -e ./utk.e
#SBATCH -o ./utk.o

pwd
module load r
module list

time mpirun -np 8 Rscript data_rf_mpi_mc.R
