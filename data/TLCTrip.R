
#' tlc_getYM: Gets one month of TLC yellow taxi data.
#' 
#' @param ym
#' Character "YYYY-MM" giving the year and month to be retrieved.
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
tlc_get_ym = function(ym, name = "yellow_tripdata", 
                     dest = "/projects/bckj/TLC_yellow",
                     url = "https://d37ci6vzurychx.cloudfront.net/trip-data") {
  d = lubridate::ym(ym)
  yr = lubridate::year(d)
  month = lubridate::month(d)

  ## Construct source url/file
  file_name = paste0(name, "_", yr, '-', sprintf('%02d', month), '.parquet')
  file_url = paste0(url, '/', file_name)
  
  ## Construct destination directory
  dest_dir = paste0(dest, "/", yr)
  if(!dir.exists(dest_dir)) dir.create(dest_dir)
  
  download.file(file_url, paste0(dest_dir, "/", file_name), method = "curl",
                quiet = TRUE)
  invisible(file_url)
}

tlc_get_range = function(first, last, cores = 1) {
  ## construct vector of yr-month-day requests
  dates = seq(lubridate::ym(first), lubridate::ym(last), "months")
  mclapply(dates, tlc_get_ym, mc.cores = cores)
}

tlc_get_range("2021-01", "2022-12", cores = 1)

