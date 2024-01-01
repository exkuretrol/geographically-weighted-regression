library(tidyverse)

dataset <- "aqx_p_13"
output_dir <- "air_quality"
path_to_input_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_preprocessed" %>% str_interp())
path_to_output_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_T" %>% str_interp())

if (!(dir.exists(path_to_output_dir))) dir.create(path_to_output_dir)

files <- list.files(path_to_input_dir, full.names = TRUE)

tryCatch(
    {
        for (file in files)
        {
            filename <- basename(file)
            message("processing file ${filename}...\t" %>% str_interp(), appendLF = FALSE)
            df <- file %>% readRDS()
            df <- df %>%
                pivot_longer(
                    cols = 0:23 %>% sprintf("%02d", .) %>% paste0("monitorvalue", .),
                    names_to = "hour",
                    values_to = "value"
                ) %>%
                mutate(
                    hour = paste0(substr(hour, 13, 14), ":00:00")
                ) %>%
                mutate(
                    monitordatetime = as.POSIXct(
                        paste(monitordate, hour),
                        fmt = "%Y-%m-%d %H:%M:%S",
                        tz = Sys.timezone()
                    )
                ) %>%
                select(-c(hour, monitordate, itemname, itemid, itemunit)) %>%
                pivot_wider(names_from = itemengname, values_from = value)
            saveRDS(df, file.path(path_to_output_dir, filename))
            message("done")
        }
    },
    warning = function(x) 
    {
        stop("converted from warning: ", conditionMessage(x))
    }
)
