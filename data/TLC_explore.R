## TLC_yellow data was written in arrow-friendly format, partitioned by yr-month

library(dplyr)
library(arrow)
library(memuse)
library(pryr)
library(parallel)

## print various measures of memory use
memuse::Sys.procmem()
memuse::Sys.meminfo()
pryr::mem_used()

## get memory use of this process from Unix "ps" command
args = paste("-o drs,rss -p", Sys.getpid())
system2("ps", args)
## DRS: (B) data resident set size, the amount of physical memory devoted to other than executable code
## RSS: (kB) resident set size, the non-swapped physical memory that a task has used (in kiloBytes).

arrow_info()

print("opening dataset")

tlc = arrow::open_dataset("/projects/bckj/TLC_yellow/year=2009")
tlc

months = 1:2

read_tlc = function(m, tlc) {
  tlc %>% filter(year == 2009, month == m) %>% collect()
}

print("into lapply")

system.time({
tlc2009 = lapply(months, read_tlc, tlc = tlc)
tlc2009 = do.call(rbind, tlc2009)
})

mean(tlc2009$Total_Amt)
rm(tlc2009)
gc()

print("into mclapply")

system.time({
  tlc2009 = mclapply(months, read_tlc, tlc = tlc, mc.cores = 4)
  tlc2009 = do.call(rbind, tlc2009)
})

mean(tlc2009$Total_Amt)

mu(tlc2009)
memuse::Sys.procmem()
memuse::Sys.meminfo()
pryr::mem_used()
