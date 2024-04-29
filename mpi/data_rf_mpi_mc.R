suppressMessages(library(pbdMPI))

suppressMessages(library(arrow))
suppressMessages(library(dplyr))
suppressMessages(...)

ds <- open_dataset("/projects/bckj/<your-parquet-data>")
get_hive_var = function(ds, var) 
  sub("/.*$", "", sub(paste0("^.*", var, "="), "", ds$files))
partitions = get_hive_var(ds, "<your-partition-var>")  

my_partitions = partitions[comm.chunk(length(partitions), form = "vector")]
comm.cat("rank", comm.rank(), "partitions", my_partitions, "\n", all.rank = TRUE)

# Read only the data for the partitions in my_partitions
my_data <- ds %>% filter(flightDate %in% my_partitions) %>% collect()

# Filter, select, mutate, and reduce the data (do separately for debug)
my_data <- my_data %>%
  filter(<your-filters>) %>% 
  select(<your-var-selections>)) %>%
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
comm.set.seed(seed = 7654321, diff = FALSE)      #<<

n = nrow(data)
n_test = floor(0.2 * n)
i_test = sample.int(n, n_test)
train = data[-i_test, ][1:1000, ]    # limit to 1k obs for debugging
my_test = data[i_test, ][comm.chunk(n_test, form = "vector"), ]    #<<

ntree = 64 # start small for debug
my_ntree = comm.chunk(ntree, form = "vector", rng = TRUE, seed = 12345)        #<<
rfc = function(i, mnt, mxn = 6) {
  comm.set.stream(i)                  #<<
  randomForest(<your-target> ~ ., train, ntree = mnt[i], maxnodes = mxn, norm.votes = FALSE) #<<
}
my_rf = mclapply(seq_along(my_ntree), rfc, mnt = my_ntree) #<<
my_rf = do.call(combine, my_rf)            #<<
rf_all = allgather(my_rf)                  #<<
rf_all = do.call(combine, rf_all)          #<<

my_pred = as.vector(predict(rf_all, my_test))

# correct = allreduce(sum(my_pred == my_test$<your-true-category>))  # classification
sse = allreduce(sum((my_pred - my_test$<your-target>)^2)) # regression
# comm.cat("Proportion Correct:", correct/(n_test), "\n")
comm.cat("RMSE:", sqrt(rmse/n_test), "\n")

finalize()