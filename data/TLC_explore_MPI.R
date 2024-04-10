library(pbdMPI)

suppressMessages(library(dplyr))
suppressMessages(library(arrow))
suppressMessages(library(memuse))
suppressMessages(library(pryr))
suppressMessages(library(parallel))

memuse::Sys.procmem()
arrow_info()

system2("tree", "/projects/bckj/TLC_yellow/")

print("opening dataset")

tlc = arrow::open_dataset("/projects/bckj/TLC_yellow/")
tlc

months = 1:12
my_months = comm.chunk(months, form = "vector")

read_tlc_month = function(m, tlc) {
  tlc %>% filter(year == 2009, month == m) %>% collect()
}

my_tlc2009 = lapply(my_months, read_tlc_month, tlc = tlc)
my_tlc2009 = do.call(rbind, my_tlc2009)
tlc2009 = gather(my_tlc2009)

if(comm.rank() == 0) {
  print("mean from rank 0:")
  print(mean(tlc2009$Total_Amt))
}

finalize()
