suppressMessages(library(lubridate, quietly = TRUE))

#' A wrapper for `download.file()` specific to TLC data to `wget` one
#' yr-month to a destination directory. Since `download.file()` engages `wget`
#' with a `system()` call, generating these calls to `tlcYM_get()` can be 
#' completely parallel and the data never touches R. 
#' @param d
#' Character "YYYY-MM-DD" giving the required date.
#' @param name
#' Character file name base (such as 'yellow_tripdata_') from the TLC 
#' repository documentation.
#' @param dest
#' Character destination directory path.
#' @param url
#' Character URL of data source location.
#' 
#' @returns 
#' Invisibly, returns the character URL/file combination used in data retrieval.
tlcYM_get = function(d, name, dest, url) {
  yr = year(d)

  ## Construct source url/file
  file_name = paste0(name, yr, '-', sprintf('%02d', month(d)), '.parquet')
  file_url = paste0(url, '/', file_name)
  
  ## Construct destination directory
  dest_dir = paste0(dest, "/", yr)
  if(!dir.exists(dest_dir)) dir.create(dest_dir)
  
  download.file(file_url, paste0(dest_dir, "/", file_name), method = "curl",
                quiet = TRUE)
  invisible(file_url)
}

## construct vector of yr-month-day requests
char_dates = as.character(seq(ym("2021-01"), ym("2023-12"), by = "months"))

mclapply(char_dates, tlcYM_get, 
       name = 'yellow_tripdata_', 
       dest = "/projects/bckj/TLC",
       url = "https://d37ci6vzurychx.cloudfront.net/trip-data",
       mc.cores = 4)
