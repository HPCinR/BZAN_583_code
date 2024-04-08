
#' tlc_get_ym: Gets one month of TLC yellow taxi data and writes it in Hive
#' style directory names, such as `dest/year=2015/month=8/file_name.parquet`.
#' 
#' @param ymd
#' A **lubridate** "YYYY-MM-01" giving the year and month to be retrieved.
#' @param name
#' Character file name base (such as 'yellow_tripdata') from the TLC 
#' repository documentation.
#' @param dest
#' Character destination directory path.
#' @param url
#' Character URL of data source location.
#' 
#' @details
#' Uses `method = wget` to get one month of TLC yellow taxi data into the
#' `dest` directory. Since `download.file()` engages `wget`
#' with a `system()` call, generating these calls to `tlcYM_get()` can be 
#' completely parallel and the data never touches R. 
#' 
#' @returns 
#' Invisibly, returns the character URL/file combination used in data retrieval.
#' 
tlc_get_ym = function(ymd, name = "yellow_tripdata", 
                     dest = "/projects/bckj/TLC_yellow",
                     url = "https://d37ci6vzurychx.cloudfront.net/trip-data") {
  yr = lubridate::year(ymd)
  month = lubridate::month(ymd)

  ## Construct source url/file
  file_name = paste0(name, "_", yr, '-', sprintf('%02d', month), '.parquet')
  file_url = paste0(url, '/', file_name)
  
  ## Construct destination directory
  dest_dir = paste0(dest, "/year=", yr)
  if(!dir.exists(dest_dir)) dir.create(dest_dir)
  dest_dir = paste0(dest_dir, "/month=", month)
  if(!dir.exists(dest_dir)) dir.create(dest_dir)
  
  download.file(file_url, paste0(dest_dir, "/", file_name), method = "curl",
                quiet = TRUE)
  invisible(file_url)
}

#' tlc_get_range: A wrapper for `tlc_get_ym()` to get a range of months and do
#' it in parallel.
#' 
#' @param first
#' Character "YYYY-MM" first month. Uses `lubridate::ym()` to read
#' @param last
#' Character "YYYY-MM" last month
#' @param cores
#' Integer number of cores to use for running `wget` instances in parallel
#' 
#' @details
#' Since the function does a system call to `wget`, its time does not include
#' the core time used by `wget` and includes only the R function time. But
#' the *real* or *elapsed* time is correct.
#' 
#' @returns
#' Invisibly returns the full vector of months retrieved
#' 
tlc_get_range = function(first, last, cores = 1) {
  ## construct vector of yr-month-day requests
  dates = seq(lubridate::ym(first), lubridate::ym(last), "months")
  parallel::mclapply(dates, tlc_get_ym, mc.cores = cores)
  invisible(dates)
}

# tlc_get_range("2021-01", "2022-12", cores = 1)



