library(tidyverse)
library(stringr)

dataset <- "aqx_p_13"
output_dir <- "air_quality"
path_to_input_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_T_yearly_interpolated" %>% str_interp())
path_to_output_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_T_daily" %>% str_interp())

if (!dir.exists(path_to_output_dir)) {dir.create(path_to_output_dir)}

files <- list.files(path_to_input_dir, full.names = TRUE)

for (year in 2020:2022)
{
    file <- file.path(path_to_input_dir, sprintf("aqx_p_13_%d.RDS", year))
    filename <- basename(file)
    message("processing file ${filename}...\t" %>% str_interp(), appendLF = FALSE)
    df <- readRDS(file)
    df <- df %>% 
        mutate(monitordate = lubridate::as_date(monitordatetime)) %>% 
        select(- monitordatetime) %>% 
        group_by(sitename, monitordate) %>% 
        summarise(across(everything(), ~ mean(.x)), .groups = 'drop') %>% 
        arrange(monitordate, sitename)
    saveRDS(df, file.path(path_to_output_dir, filename))
    message("done")
}
