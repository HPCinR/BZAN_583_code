suppressMessages(library(lubridate, quietly = TRUE))

#' Function to wget and write one yr-month
#' @param d
#' Character "YYYY-MM"
#' @param name
#' Character file name base (such as 'yellow_tripdata_')
#' @param dest
#' Character destination directory
#' @param url
#' Character URL of data location
tlcYM_get = function(d, name, dest, url) {
  yr = year(d)
  file_name = paste0(name, yr, '-', sprintf('%02d', month(d)), '.parquet')
  file_url = paste0(url, '/', file_name)
  dest_dir = paste0(dest, "/", yr)
  if(!dir.exists(dest_dir)) dir.create(dest_dir)
  
  print(file_url)
  download.file(file_url, paste0(dest_dir, "/", file_name), method = "curl",
                quiet = TRUE)
}

## construct vector of yr-month-day requests
char_dates = as.character(seq(ym("2021-01"), ym("2023-12"), by = "months"))

mclapply(char_dates, tlcYM_get, 
       name = 'yellow_tripdata_', 
       dest = "/projects/bckj/TLC",
       url = "https://d37ci6vzurychx.cloudfront.net/trip-data",
       mc.cores = 4)


