## 

library(data.table)
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

print("opening dataset")
dir = "/projects/bckj/TLC_yellow_csv/year=2009"

months = 1:2

read_tlc = function(m, tlc) {
  file = paste0(dir, "/month=", m, "/part-0.csv")
  data.table::fread(file)
}

print("into lapply")
system.time({
tlc2009 = lapply(months, read_tlc, tlc = tlc)
tlc2009 = do.call(rbind, tlc2009)
})

mean(tlc2009$Total_Amt)
rm(tlc2009)

print("into mclapply")
system.time({
  tlc2009 = mclapply(months, read_tlc, tlc = tlc, mc.cores = 2)
  tlc2009 = do.call(rbind, tlc2009)
})

mean(tlc2009$Total_Amt)

memuse::mu(tlc2009)
memuse::Sys.procmem()
pryr::mem_used()

dim(tlc2009)