suppressMessages(library(lubridate, quietly = TRUE))

get_TLCData = function(start, end, name, dir, url, dest, method = "wget", quiet = TRUE) {
  start = ym(start)
  end = ym(end)

  char_dates = as.character(seq(start, end, by = "months"))
  for (d in char_dates) {
    yr = year(d)
    file_name = paste0(name, yr, '-', sprintf('%02d', month(d)), '.parquet')
    file_url = paste0(url, '/', dir, '/', file_name)
    dest_dir = paste0(dest, "/", yr)
    if(!dir.exists(dest_dir)) dir.create(dest_dir)

    system.time({
    download.file(file_url, paste0(dest_dir, "/", file_name), method = method, quiet = quiet)
    })
  }
}

dest = "/projects/bckj/TLC"
# dest = "~/UTK/NYTaxi/"
url = "https://d37ci6vzurychx.cloudfront.net"
get_TLCData(start = "2009-03", end = "2009-03", name = 'yellow_tripdata_',
            dir = 'trip-data', url = url, dest = dest, method = "curl", quiet = TRUE)
# get_TLCData(start = "2009-01", end = "2009-02", name = 'green_tripdata_',
#             dir = 'trip-data', url = url, dest = dest)
# get_TLCData(start = "2009-01", end = "2009-02", name = 'fhv_tripdata_',
#             dir = 'trip-data', url = url, dest = dest)
