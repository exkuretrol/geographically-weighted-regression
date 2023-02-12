library(tidyverse)
library(stringr)

dataset <- "aqx_p_13"
output_dir <- "air_quality"
path_to_input_dir <- file.path(getwd(), output_dir, "${dataset}_RDS" %>% str_interp())
path_to_output_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_preprocessed" %>% str_interp())

if (!dir.exists(path_to_output_dir)) {dir.create(path_to_output_dir)}

files <- list.files(path_to_input_dir, full.names = TRUE)

generate_empty_dataframe <- function() {
    df <- c(
        "filename",
        "year",
        "month",
        "duplicated_rows"
    ) %>%
        paste(collapse = ",") %>%
        I() %>%
        readr::read_csv(
            col_types = "ciic"
        )
    return(df)
}

summary_dataframe <- generate_empty_dataframe()

for (file in files)
{
    df <- readRDS(file)

    duplicated_rows <- df %>%
        duplicated %>% 
        which %>% 
        paste0(collapse = ",")
    
    df <- df %>% 
        distinct
    filename <- basename(file)
    filename_no_ext <- filename %>%
        tools::file_path_sans_ext()
    
    summary_dataframe <- summary_dataframe %>% add_row(
        filename = filename_no_ext,
        year = substr(filename_no_ext, 10, 13) %>% as.integer(),
        month = substr(filename_no_ext, 14, 15) %>% as.integer(),
        duplicated_rows = duplicated_rows
    )
    
    saveRDS(df, file.path(path_to_output_dir, filename))
}
