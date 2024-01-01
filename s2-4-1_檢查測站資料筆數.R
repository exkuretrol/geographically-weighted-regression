dataset <- "aqx_p_13"
output_dir <- "air_quality"
path_to_output_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_T_yearly_interpolated" %>% str_interp())

aqx_p_13_2020 <- readRDS(file.path(path_to_output_dir, "aqx_p_13_2020.RDS"))
aqx_p_13_2021 <- readRDS(file.path(path_to_output_dir, "aqx_p_13_2021.RDS"))
aqx_p_13_2022 <- readRDS(file.path(path_to_output_dir, "aqx_p_13_2022.RDS"))

library(zoo)

aqx_p_13_2020 %>% 
    group_by(sitename) %>% 
    summarize(n = n())

aqx_p_13_2021 %>% 
    group_by(sitename) %>% 
    summarize(n = n())

aqx_p_13_2022 %>% 
    group_by(sitename) %>% 
    summarize(n = n())
