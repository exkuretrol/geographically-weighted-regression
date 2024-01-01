dataset <- "aqx_p_13"
output_dir <- "air_quality"
path_to_output_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_T_yearly_filled" %>% str_interp())

aqx_p_13_2020 <- readRDS(file.path(path_to_output_dir, "aqx_p_13_2020.RDS"))
aqx_p_13_2021 <- readRDS(file.path(path_to_output_dir, "aqx_p_13_2021.RDS"))
aqx_p_13_2022 <- readRDS(file.path(path_to_output_dir, "aqx_p_13_2022.RDS"))

aqx_p_13_2020_colnames <- colnames(aqx_p_13_2020)
aqx_p_13_2021_colnames <- colnames(aqx_p_13_2021)
aqx_p_13_2022_colnames <- colnames(aqx_p_13_2022)
per_data_colnames <- list(
    aqx_p_13_2020 = aqx_p_13_2020_colnames,
    aqx_p_13_2021 = aqx_p_13_2021_colnames,
    aqx_p_13_2022 = aqx_p_13_2022_colnames
)

all_columns <- Reduce(union, per_data_colnames)

summary_missing_dataframe <- data.frame(sapply(all_columns, \(x) double()))
colnames(summary_missing_dataframe) <- all_columns

aqx_p_13_2020_missing <- aqx_p_13_2020 %>%
    select(-c(1:3)) %>%
    summarize((across(everything(), ~ sum(is.na(.))) / nrow(.)) * 100 %>% round()) %>%
    as.data.frame() %>%
    `row.names<-`("aqx_p_13_2020")

aqx_p_13_2021_missing <- aqx_p_13_2021 %>%
    select(-c(1:3)) %>%
    summarize((across(everything(), ~ sum(is.na(.))) / nrow(.)) * 100 %>% round()) %>%
    as.data.frame() %>%
    `row.names<-`("aqx_p_13_2021")

aqx_p_13_2022_missing <- aqx_p_13_2022 %>%
    select(-c(1:3)) %>%
    summarize((across(everything(), ~ sum(is.na(.))) / nrow(.)) * 100 %>% round()) %>%
    as.data.frame() %>%
    `row.names<-`("aqx_p_13_2022")

for (j in list(aqx_p_13_2020_missing, aqx_p_13_2021_missing, aqx_p_13_2022_missing))
{
    for (i in seq(length(j)))
    {
        cell <- j[i]
        summary_missing_dataframe[rownames(cell), colnames(cell)] <- cell
    }
}

summary_missing_dataframe_rounded <- summary_missing_dataframe %>%
    select(-c(1:3)) %>%
    round(digits = 1)

View(summary_missing_dataframe_rounded)

library(visdat)

source(file = file.path(getwd(), "utilities.R"))

base_num <- 6
figure_width <- 4 * base_num
figure_height <- 3 * base_num

# TODO: sample by sitename
aqx_p_13_2020 %>%
    select(-monitordatetime) %>% 
    slice_sample(n = 3000) %>%
    vis_miss(facet = sitename) %>%
    save_ggplot2_plot(
        filename = "missing_value_by_year_2020.png",
        width = figure_width, 
        height = figure_height
    )

aqx_p_13_2021 %>%
    select(-monitordatetime) %>% 
    slice_sample(n = 3000, ) %>%
    vis_miss(facet = sitename) %>%
    save_ggplot2_plot(
        filename = "missing_value_by_year_2021.png",
        width = figure_width, 
        height = figure_height
    )

aqx_p_13_2022 %>%
    select(-monitordatetime) %>% 
    slice_sample(n = 3000) %>%
    vis_miss(facet = sitename) %>%
    save_ggplot2_plot(
        filename = "missing_value_by_year_2022.png",
        width = figure_width, 
        height = figure_height
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
    select(-monitordatetime) %>% 
    select(-deselect_columns) %>% 
    slice_sample(n = 3000) %>%
    vis_miss(facet = sitename) %>%
    save_ggplot2_plot(
        filename = "missing_value_by_year_2020_filtered.png",
        width = 20, 
        height = 15
    )

aqx_p_13_2021 %>%
    select(-monitordatetime) %>% 
    select(-deselect_columns) %>% 
    slice_sample(n = 3000) %>%
    vis_miss(facet = sitename) %>%
    save_ggplot2_plot(
        filename = "missing_value_by_year_2021_filtered.png",
        width = 20, 
        height = 15
    )

aqx_p_13_2022 %>%
    select(-monitordatetime) %>% 
    select(-deselect_columns_22) %>% 
    slice_sample(n = 3000) %>%
    vis_miss(facet = sitename) %>%
    save_ggplot2_plot(
        filename = "missing_value_by_year_2022_filtered.png",
        width = 20, 
        height = 15
    )
