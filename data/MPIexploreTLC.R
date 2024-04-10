library(pbdMPI)

suppressMessages(library(dplyr))
suppressMessages(library(arrow))
suppressMessages(library(memuse))
suppressMessages(library(pryr))
suppressMessages(library(parallel))

memuse::Sys.procmem()
arrow_info()

system2("tree", "/projects/bckj/TLC_yellow/year=2009")

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

finalize()
