library(tidyverse)
library(stringr)
library(visdat)

dataset <- "aqx_p_13"
output_dir <- "air_quality"
path_to_input_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_T_yearly" %>% str_interp())

files <- list.files(path_to_input_dir, full.names = TRUE)
# df <- readRDS(files[1])
# available_variable <- df %>% colnames %>% `[`(-(1:3))

# less than zero?
# [ ] SO2_ppb
# [ ] CO_ppm
# [ ] O3_ppb
# [ ] PM10_μg/m3
# [ ] NOx_ppb
# [ ] NO_ppb
# [ ] NO2_ppb
# [ ] THC_ppm
# [ ] NMHC_ppm
# [ ] WIND_SPEED_m/sec
# [ ] WIND_DIREC_degrees 0-360
# [x] AMB_TEMP_℃
# [ ] RAINFALL_mm
# [ ] CH4_ppm
# [ ] PM2.5_μg/m3
# [ ] RH_%
# [ ] WS_HR_m/sec
# [ ] WD_HR_degrees 0-360
# [ ] RAIN_INT_㎜
# [ ] CO2_ppm

summary_dataframe <- tibble()
all_years <- tibble()

for (file in files)
{
    filename <- basename(file)
    filename_no_ext <- filename %>%
        tools::file_path_sans_ext()
    
    df <- readRDS(file)

    # check value is less than zero
    # store with list? string
    
    df <- df %>% 
        # 溫度可能 < 0
        mutate(
            across(
                # datetime 也是一種 double
                where(~ is.double(.x)) & !`AMB_TEMP_℃` & !monitordatetime, 
                ~ case_when(
                    .x < 0 ~ NA,
                    .default = .x
                )
            )
        )
    
    # NAs
    NAs <- df %>% 
        summarise(
            across(
                where(~ is.double(.x)) & !monitordatetime, 
                ~ sum(is.na(.x))
                # .names = "NA_{.col}"
            )
        ) %>% 
        mutate(Year = filename %>% substr(10, 13), .before = 1)
    all_years <- df %>% 
        mutate(Year = filename %>% substr(10, 13), .before = 1) %>% 
        bind_rows(all_years, .)
    
    summary_dataframe <- bind_rows(summary_dataframe, NAs)
}
saveRDS(summary_dataframe, file.path(output_dir, "statistics", "summary_dataframe.RDS"))

all_years %>% select(- c(2:4)) %>% slice_sample(by = Year, n = 20000) %>% vis_miss(facet = Year, warn_large_data = FALSE)
