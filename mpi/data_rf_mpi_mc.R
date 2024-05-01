## All of the following need to be replaced with your data:
## your_parquet_data, your_target, your_filters, your_var_selections,
## your_true_category, your_partition_var
##

suppressMessages(library(pbdMPI))
suppressMessages(library(arrow))
suppressMessages(library(dplyr))

ds <- open_dataset("/projects/bckj/your_parquet_data")
get_hive_var = function(ds, var) 
  sub("/.*$", "", sub(paste0("^.*", var, "="), "", ds$files))
partitions = get_hive_var(ds, "your_partition_var")  

my_partitions = partitions[comm.chunk(length(partitions), form = "vector")]
comm.cat("rank", comm.rank(), "partitions", my_partitions, "\n", all.rank = TRUE)

# Read only the data for the partitions in my_partitions
my_data <- ds %>% filter(flightDate %in% my_partitions) %>% collect()

# Filter, select, mutate, and reduce the data (do separately for debug)
my_data <- my_data %>%
  filter(your_filters) %>% 
  select(your_var_selections) %>%
  drop_na() %>% collect()

comm.cat(comm.rank(), "dim", dim(my_data), "\n", all.rank = TRUE)

## allgather() for data.frames (not in pbdMPI ... yet!)
allgather.data.frame = function(x) {
  cnames = names(x)
  x = lapply(x, function(x) do.call(c, allgather(x)))
  x = as.data.frame(x)
  names(x) = cnames
  x
}

data = allgather.data.frame(my_data)
rm(my_data) # free up memory

## Check on the result
comm.cat(comm.rank(), "dim", dim(data), "\n", all.rank = TRUE)
comm.print(memuse::Sys.procmem()$size, all.rank = TRUE)

## Parallel random forest part
suppressMessages(library(randomForest))
suppressMessages(library(parallel))
comm.set.seed(seed = 7654321, diff = FALSE) 

i_samp = sample.int(nrow(data), 1e5)
data = data[i_samp, ]    # limit to 100k obs for debugging

n = nrow(data)
n_test = floor(0.2 * n)
i_test = sample.int(n, n_test)
train = data[-i_test, ]
my_test = data[i_test, ][comm.chunk(n_test, form = "vector"), ] 
rm(data)  # no longer needed, free up memory

## start with nodesize at 1% of the data and small ntree
ntree = 64
my_ntree = comm.chunk(ntree, form = "number", rng = TRUE, seed = 12345)
rF = function(nt, tr) 
  randomForest(your_target ~ ., data = tr, ntree = nt, nodesize = 1e3, norm.votes = FALSE) 
nc = as.numeric(commandArgs(TRUE)[2]) 
rf = mclapply(seq_len(my_ntree), rF, tr = train, mc.cores = nc)
rf = do.call(combine, rf)  # reusing rf name to release memory after operation
rf = allgather(rf) 
rf = do.call(combine, rf)

my_pred = as.vector(predict(rf_all, my_test))

# correct = allreduce(sum(my_pred == my_test$your_true_category))  # classification
sse = allreduce(sum((my_pred - my_test$your_target)^2)) # regression
rmse = sqrt(sse/n_test)
# comm.cat("Proportion Correct:", correct/(n_test), "\n")
comm.cat("RMSE:", rmse, "\n")
mean = allreduce(sum(my_test$your_target)) / n_test
comm.cat("Mean:", mean, "\n")
comm.cat("Coefficient of Variation:", 100*sqrt(sse/n_test)/mean, "\n")

finalize()