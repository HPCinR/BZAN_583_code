## This script describes two levels of parallelism:
## Top level: Distributed MPI runs several copies of this entire script. Instances differ by their comm.rank() designation.
## Inner level: The unix fork (copy-on-write) shared memory parallel execution of the mc.function() managed by parallel::mclapply()
## Further levels are possible: multithreading in compiled code and communicator splitting at the distributed MPI level.

suppressMessages(library(pbdMPI))
comm.print(sessionInfo())

host = system("hostname", intern = TRUE)  # get node name

mc.function = function(x) {
    Sys.sleep(0.1) # replace with your function for mclapply cores here
    Sys.getpid() # returns process id
}

## ranks and cores queries
ranks_on_my_node = Sys.getenv("SLURM_NTASKS_PER_NODE")
my_cores = Sys.getenv("SLURM_CPUS_PER_TASK")
cores_on_my_node = Sys.getenv("SLURM_CPUS_ON_NODE")
cores_total = allreduce(my_cores)  # adds up over ranks

## Run mclapply on allocated cores to demonstrate fork pids
my_pids = parallel::mclapply(seq_len(my_cores), mc.function, mc.cores = my_cores)
my_pids = do.call(paste, my_pids) # combines results from mclapply
##
## Same cores are shared with OpenBLAS (see flexiblas package) or for other OpenMP enabled codes outside mclapply.
## If BLAS functions are called inside mclapply, they compete for the same cores: avoid or manage appropriately!!!

## Now report what happened and where
msg = paste0("Hello World from rank ", comm.rank(), " on host ", host, " with ", my_cores, " cores allocated\n",
             "            (", ranks_on_my_node, " R sessions sharing ", cores_on_my_node, " cores on this host node).\n",
             "      pid: ", my_pids, "\n")
comm.cat(msg, quiet = TRUE, all.rank = TRUE)

comm.cat("Total R sessions:", comm.size(), "Total cores:", cores_total, "\n",
         quiet = TRUE)
comm.cat("\nNotes: pid to core map changes frequently during mclapply\n",
         quiet = TRUE)

finalize()
