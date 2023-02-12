library(tidyverse)
library(stringr)

dataset <- "aqx_p_13"
output_dir <- "air_quality"
path_to_input_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_T" %>% str_interp())

files <- list.files(path_to_input_dir, full.names = TRUE)

generate_empty_dataframe <- function() {
    df <- c(
        "filename",
        "year",
        "month",
        "available_variable",
        "value_less_than_zero",
        "NAs"
    ) %>%
        paste(collapse = ",") %>%
        I() %>%
        readr::read_csv(
            col_types = "ciiccc"
        )
    return(df)
}

summary_dataframe <- generate_empty_dataframe()

for (file in files)
{
    df <- readRDS(file)
    
    # NAs
    NAs <- df %>% 
        select(- monitordatetime) %>% 
        summarise(across(where(~ is.double(.x)), ~ sum(is.na(.x)))) %>% 
        unlist %>% 
        unname %>% 
        paste(collapse = ",")

    # check value is less than zero
    # store with list? string
    value_less_than_zero <- df %>% 
        # 溫度可能 < 0
        select(- c(monitordatetime, `AMB_TEMP_℃`)) %>% 
        mutate(across(where(~ is.double(.x)), ~ replace_na(.x, 99999))) %>% 
        summarise(across(where(~ is.double(.x)), ~ sum(.x < 0))) %>%
        unlist %>% 
        unname %>% 
        paste0(collapse = ",")
    
    # print which cell is less than zero
    # df %>%
    #     select(- monitordate) %>%
    #     filter(itemname != "溫度") %>% 
    #     filter(if_any(where(~ is.double(.x)), ~ .x < 0)) %>%
    #     View
    
    filename <- basename(file)
    filename_no_ext <- filename %>%
        tools::file_path_sans_ext()

    summary_dataframe <- summary_dataframe %>% add_row(
        filename = filename_no_ext,
        year = substr(filename_no_ext, 10, 13) %>% as.integer(),
        month = substr(filename_no_ext, 14, 15) %>% as.integer(),
        available_variable = df %>% colnames %>% `[`(-(1:3)) %>% paste0(collapse = ","),
        value_less_than_zero = value_less_than_zero,
        NAs = NAs
    )
}
