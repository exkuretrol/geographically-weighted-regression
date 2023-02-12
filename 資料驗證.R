library(tidyverse)
library(stringr)

dataset <- "aqx_p_13"
output_dir <- "air_quality"
path_to_output_dir <- file.path(getwd(), output_dir, "${dataset}_RDS" %>% str_interp())

files <- list.files(path_to_output_dir, full.names = TRUE)

tibble()
generate_empty_dataframe <- function()
{
    df <- c(
        "filename",
        "year",
        "month",
        "duplicated_rows",
        "value_less_than_zero"
    ) %>%
        paste(collapse = ",") %>%
        I() %>%
        readr::read_csv(
            col_types = "ciiii"
        )
    return(df)
}
summary_dataframe <- generate_empty_dataframe()

# for (file in files)
# {
    df <- readRDS(files[1])
    duplicated_rows <- df %>% 
        duplicated() %>%
        sum()
    df %>% 
    
    filename <- basename(files[1]) %>% 
        tools::file_path_sans_ext()
    
    
    
    summary_dataframe <- summary_dataframe %>% add_row(
        filename = filename,
        year = substr(filename, 10, 13) %>% as.integer(),
        month = substr(filename, 14, 15) %>% as.integer(),
        duplicated_rows = 0L,
        value_less_than_zero = 0L 
    )
    
# }