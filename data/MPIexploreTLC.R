library(pbdMPI)

suppressMessages(library(dplyr))
suppressMessages(library(arrow))
suppressMessages(library(memuse))
suppressMessages(library(pryr))
suppressMessages(library(parallel))

memuse::Sys.procmem()

print("opening dataset")
tlc = arrow::open_dataset("/projects/bckj/TLC_yellow/year=2009")
tlc

my_months = comm.chunk(4, form = "vector")

read_tlc_month = function(m, tlc) {
  tlc %>% filter(month == m) %>% collect()
}

my_tlc2009 = lapply(my_months, read_tlc_month, tlc = tlc)
my_tlc2009 = do.call(rbind, my_tlc2009)

Total_mean = comm.mean(my_tlc2009$Total_Amt)
comm.print(Total_mean)

tlc2009 = allgather(my_tlc2009)
comm.cat("my_dim:", dim(my_tlc2009), "\n")
comm.cat("dim:", dim(tlc2009), "\n")

Total_mean = mean(tlc2009$Total_Amt)
comm.print(Total_mean)

finalize()
