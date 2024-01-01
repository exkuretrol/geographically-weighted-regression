dataset <- "aqx_p_13"
output_dir <- "air_quality"
path_to_input_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_T_yearly_filled" %>% str_interp())
path_to_output_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_T_yearly_interpolated" %>% str_interp())

if (!dir.exists(path_to_output_dir))
    dir.create(path_to_output_dir)

aqx_p_13_2020 <- readRDS(file.path(path_to_input_dir, "aqx_p_13_2020.RDS"))
aqx_p_13_2021 <- readRDS(file.path(path_to_input_dir, "aqx_p_13_2021.RDS"))
aqx_p_13_2022 <- readRDS(file.path(path_to_input_dir, "aqx_p_13_2022.RDS"))

library(zoo)

deselect_sitenames <- c(
    "三重",
    "大同",
    "淡水",
    "陽明",
    "關山"
)

deselect_columns <- c(
    "THC",
    "NMHC",
    "CH4",
    "PH_RAIN",
    "RAIN_COND",
    "RAIN_INT",
    "CO2"
)

deselect_columns_22 <- c(
    "THC",
    "NMHC",
    "CH4",
    # "PH_RAIN",
    # "RAIN_COND",
    "RAIN_INT",
    "CO2"
)

aqx_p_13_2020 %>% 
    select(-deselect_columns) %>% 
    filter(!(sitename %in% deselect_sitenames)) %>% 
    group_by(sitename) %>% 
    mutate(across(-c(monitordatetime), ~na.spline(.x, na.rm = FALSE))) %>% 
    ungroup(sitename) %>%
    saveRDS(file = file.path(path_to_output_dir, "aqx_p_13_2020.RDS"))
    # slice_sample(n = 3000) %>%
    # vis_miss(facet = sitename)
    # filter(if_any(everything(), is.na)) %>% View

aqx_p_13_2021 %>% 
    select(-deselect_columns) %>% 
    filter(!(sitename %in% deselect_sitenames)) %>% 
    group_by(sitename) %>% 
    mutate(across(-c(monitordatetime), ~na.spline(.x, na.rm = FALSE))) %>% 
    ungroup(sitename) %>% 
    saveRDS(file = file.path(path_to_output_dir, "aqx_p_13_2021.RDS"))

aqx_p_13_2022 %>% 
    select(-deselect_columns_22) %>% 
    filter(!(sitename %in% deselect_sitenames)) %>% 
    group_by(sitename) %>% 
    mutate(across(-c(monitordatetime), ~na.spline(.x, na.rm = FALSE))) %>% 
    ungroup(sitename) %>% 
    saveRDS(file = file.path(path_to_output_dir, "aqx_p_13_2022.RDS"))


aqx_p_13_2020 <- readRDS(file.path(path_to_output_dir, "aqx_p_13_2020.RDS"))
aqx_p_13_2021 <- readRDS(file.path(path_to_output_dir, "aqx_p_13_2021.RDS"))
aqx_p_13_2022 <- readRDS(file.path(path_to_output_dir, "aqx_p_13_2022.RDS"))

aqx_p_13_2020 %>% 
    select(-monitordatetime) %>% 
    slice_sample(n = 3000) %>%
    vis_miss(facet = sitename) %>%
    save_ggplot2_plot(
        filename = "missing_value_by_year_2020_interpolated.png",
        width = 20, 
        height = 15
    )

aqx_p_13_2021 %>% 
    select(-monitordatetime) %>% 
    slice_sample(n = 3000) %>%
    vis_miss(facet = sitename) %>%
    save_ggplot2_plot(
        filename = "missing_value_by_year_2021_interpolated.png",
        width = 20, 
        height = 15
    )

aqx_p_13_2022 %>% 
    select(-monitordatetime) %>% 
    slice_sample(n = 3000) %>%
    vis_miss(facet = sitename) %>%
    save_ggplot2_plot(
        filename = "missing_value_by_year_2022_interpolated.png",
        width = 20, 
        height = 15
    )
