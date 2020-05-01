# Download Patricia Bender Salaries
# https://www.eskimo.com/~pbender/

# ---- start --------------------------------------------------------------

library("tidyverse")
library("rvest")

# Create a directory for the data
local_dir    <- "0-data/salaries"
data_source  <- paste0(local_dir, "/raw")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(data_source)) dir.create(data_source, recursive = T)

# ---- download ------------------------------------------------------------

# Format:
# "https://www.eskimo.com/~pbender/misc/salaries16.txt"
# "https://www.eskimo.com/~pbender/misc/salaries86.txt"
seasons       <- str_pad(c(86, 88, 89, 91:99, 0:16), 2, "left", "0")
bender_urls <- paste0("https://www.eskimo.com/~pbender/misc/salaries",
                      seasons, ".txt")

map(bender_urls, function(x){
  file_x <- paste0(data_source, "/", basename(x))
  if (!file.exists(file_x)) {
    Sys.sleep(runif(1, 2, 3))
    download.file(x, file_x, method = "wget")
  }
})

