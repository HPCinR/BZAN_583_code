## TLC_yellow data was written in arrow-friendly format, partitioned by yr-month

library(dplyr)
library(arrow)
library(memuse)
library(pryr)

## print various measures of memory use
memuse::Sys.procmem()
memuse::Sys.meminfo()
pryr::mem_used()

## get memory use of this process from Unix "ps" command
args = paste("-o drs,rss -p", Sys.getpid())
system2("ps", args)
## DRS: (B) data resident set size, the amount of physical memory devoted to other than executable code
## RSS: (kB) resident set size, the non-swapped physical memory that a task has used (in kiloBytes).

tlc = arrow::open_dataset("/projects/bckj/TLC_yellow/")
tlc

system2("tree", "/projects/bckj/TLC_yellow/")

memuse::Sys.procmem()
memuse::Sys.meminfo()
pryr::mem_used()

tlc200901 = tlc %>% filter(year == 2009, month == 1)

memuse::mu(tlc200901, prefix = "SI")
pryr::object_size(tlc200901)
object.size(tlc200901)

tlc200901 = tlc200901 %>% collect()

memuse::mu(tlc200901, prefix = "SI")
pryr::object_size(tlc200901)
object.size(tlc200901)

