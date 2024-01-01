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

common_columns <- Reduce(intersect, per_data_colnames)

all_columns <- Reduce(union, per_data_colnames)

summary_colnames_dataframe <- data.frame(sapply(all_columns, \(x) character()))
colnames(summary_colnames_dataframe) <- all_columns

empty_row <- data.frame(t(sapply(all_columns, \(x) "❌")))
colnames(empty_row) <- all_columns

for (name in names(per_data_colnames))
{
    rownames(empty_row) <- name
    summary_colnames_dataframe <- summary_colnames_dataframe %>% rbind(empty_row)
    for (colname in per_data_colnames[[name]])
    {
        if (colname %in% all_columns)
            summary_colnames_dataframe[name, colname] = ""
    }
}

View(summary_colnames_dataframe)


