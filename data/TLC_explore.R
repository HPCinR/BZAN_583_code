
arrow_tlc_read_ym = function(ymd, name = "yellow_tripdata", 
                                dir = "/projects/bckj/TLC_yellow") {
  yr = lubridate::year(ymd)
  month = lubridate::month(ymd)
  file_name = paste0(name, "_", yr, '-', sprintf('%02d', month), '.parquet')
  tlc_dat = arrow::read_parquet(paste0(dir, "/", yr, "/", file_name), mmap = FALSE)
  tlc_dat  
}

arrow_tlc_read = function(first, last, cores = 1) {
  dates = seq(lubridate::ym(first), lubridate::ym(last), "months")
  tlc_dat = lapply(dates, arrow_tlc_read_ym)
  do.call(rbind, tlc_dat)
}

system.time({tlc2022 = arrow_tlc_read("2022-01", "2022-12", cores = 4)})

names(tlc2022)
dim(tlc2022)
class(tlc2022)
head(tlc2022)
