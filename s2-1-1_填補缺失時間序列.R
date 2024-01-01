library(stringr)
library(tidyverse)
library(lubridate)

dataset <- "aqx_p_13"
output_dir <- "air_quality"
path_to_input_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_T_yearly" %>% str_interp())
path_to_output_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_T_yearly_filled" %>% str_interp())

if (!(dir.exists(path_to_output_dir))) dir.create(path_to_output_dir)

files <- list.files(path_to_input_dir, full.names = TRUE)

target_sitenames <- metadata %>% 
    # remove site 85, 60
    filter(!(siteid %in% c(60, 85))) %>% 
    select (sitename) %>% 
    pull()
    
for (year in 2020:2022)
{
    ts <- NULL
    empty_dataframe <- c(
        "sitename",
        "monitordatetime"
    ) %>%
        paste(collapse = ",") %>%
        I() %>%
        readr::read_csv(
            col_types = "cT"
        )
    filename <- paste0(dataset, "_", year, ".RDS")
    file <- file.path(path_to_input_dir, filename)
    
    days <- seq(
        from = as.Date("${year}-01-01" %>% str_interp()),
        to = as.Date("${year}-12-31" %>% str_interp()),
        by = "day"
    )

    for (day in days)
    {
        for (hour in 0:23)
        {
            s <- paste(as.Date(day), "${hour}:00:00" %>% str_interp())
            ts <- c(ts, as.POSIXct(s))
        }
    }
    
    for (sitename in target_sitenames)
    {
        t <- tibble(
            sitename = sitename,
            monitordatetime = as.POSIXct(ts)
        )
        empty_dataframe <- rbind(empty_dataframe, t)
    }

    formatted_dataframe <- empty_dataframe %>%
        mutate(
            sitename = factor(sitename, levels = target_sitenames),
            monitordate = lubridate::as_date(monitordatetime)
        ) %>%
        arrange(monitordate, sitename) %>%
        mutate(sitename = as.character(sitename)) %>%
        select(-monitordate)
    target_df <- readRDS(file)
    filled_df <- formatted_dataframe %>% 
        left_join(
            target_df, 
            by = join_by(
                sitename == sitename,
                monitordatetime == monitordatetime
            )
        ) %>%
            mutate(across(everything(), ~replace(., is.nan(.), NA)))
    
    saveRDS(filled_df, file.path(path_to_output_dir, filename))
}

