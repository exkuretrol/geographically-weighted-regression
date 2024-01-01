library(tidyverse)
library(stringr)

dataset <- "aqx_p_13"
output_dir <- "air_quality"
path_to_input_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_T" %>% str_interp())
path_to_output_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_T_yearly" %>% str_interp())

if (!dir.exists(path_to_output_dir))
    dir.create(path_to_output_dir)

for (year in 2020:2022)
{
    yearly_df <- tibble()
    for (month in 1:12)
    {
        file <- file.path(path_to_input_dir, sprintf("aqx_p_13_%d%02d.RDS", year, month))
        df <- readRDS(file)
        yearly_df <- bind_rows(yearly_df, df)
    }
    saveRDS(yearly_df, file.path(path_to_output_dir, sprintf("aqx_p_13_%d.RDS", year)))
}

