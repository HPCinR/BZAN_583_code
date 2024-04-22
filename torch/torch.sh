#!/bin/bash
#SBATCH --mem=32g
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16     # <- match to OMP_NUM_THREADS
#SBATCH --partition=gpuA100x4-preempt
#SBATCH --time=00:10:00
#SBATCH --account=bckj-delta-gpu
#SBATCH --job-name=utk
#SBATCH -e ./utk.e
#SBATCH -o ./utk.o
### GPU options ###
#SBATCH --gpus-per-node=1
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=verbose,per_task:1
###SBATCH --gpu-bind=none     # <- or closest

module purge # drop modules and explicitly load the ones needed
             # (good job metadata and reproducibility)
             
module avail

#module load anaconda3_gpu
module load r
module list  # job documentation and metadata

echo "job is starting on `hostname`"

#which python3
#conda list tensorflow
#srun python3 \
#  tf_gpu.py

Rscript -e "torch_tensor(1, device = "cuda")"

exit
