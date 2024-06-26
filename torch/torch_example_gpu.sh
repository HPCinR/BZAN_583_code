#!/bin/bash
#SBATCH --mem=32g
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16     # <- match to OMP_NUM_THREADS
#SBATCH --partition=gpuA100x4-preempt
#SBATCH --time=00:20:00
#SBATCH --account=bckj-delta-gpu
#SBATCH --job-name=utk
#SBATCH -e ./utk.e
#SBATCH -o ./utk.o
### GPU options ###
#SBATCH --gpus-per-node=1
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=verbose,per_task:1

module load r
module list 

echo "job is starting on `hostname`"

time Rscript torch_example_gpu.R

exit
