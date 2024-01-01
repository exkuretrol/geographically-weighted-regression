library(tidyverse)
library(stringr)

dataset <- "aqx_p_13"
output_dir <- "air_quality"
path_to_input_dir <- file.path(getwd(), output_dir, "${dataset}_RDS" %>% str_interp())
path_to_output_dir <- file.path(getwd(), output_dir, "${dataset}_RDS_preprocessed" %>% str_interp())

if (!dir.exists(path_to_output_dir)) {
    dir.create(path_to_output_dir)
}

metadata <- metadata %>%
    select(siteid, sitename) %>%
    # `colnames<-`(., toupper(colnames(metadata))) %>%
    as.data.frame()

files <- list.files(path_to_input_dir, full.names = TRUE)

generate_empty_dataframe <- function() {
    df <- c(
        "filename",
        "year",
        "month",
        "duplicated_rows",
        "duplicated_rows_num",
        "num_of_rows"
    ) %>%
        paste(collapse = ",") %>%
        I() %>%
        readr::read_csv(
            col_types = "ciicii"
        )
    return(df)
}

summary_dataframe <- generate_empty_dataframe()

summary_duplicated_dataframe <- data.frame(
    list(
        filename = character(),
        normal_record = integer(),
        duplicated_record = integer()
    )
)

summary_site_nums <- data.frame(
    list(
        filename = character(),
        site_nums = integer()
    )
)


get_siteid <- function(sitename) {
    return(metadata[which(metadata$sitename == sitename), "siteid"])
}

get_sitename <- function(siteid) {
    return(metadata[which(metadata$siteid == siteid), "sitename"])
}

for (file in files)
{
    df <- readRDS(file)
    filename <- basename(file)
    filename_no_ext <- filename %>%
        tools::file_path_sans_ext()

    num_of_rows <- nrow(df)

    summary_site_nums <- summary_site_nums %>%
        add_row(
            filename = filename_no_ext,
            site_nums = df$sitename %>% unique() %>% length()
        )

    duplicated_rows <- df %>%
        duplicated() %>%
        which() %>%
        paste0(collapse = ",")

    duplicated_rows_num <- df %>%
        duplicated() %>%
        sum()


    df <- df %>%
        distinct() %>%
        left_join(x = ., y = metadata, by = "sitename") %>%
        mutate(
            siteid = dplyr::coalesce(siteid.x, siteid.y)
        ) %>%
        select(-c(siteid.x, siteid.y)) %>%
        select(siteid, everything())

    summary_dataframe <- summary_dataframe %>% add_row(
        filename = filename_no_ext,
        year = substr(filename_no_ext, 10, 13) %>% as.integer(),
        month = substr(filename_no_ext, 14, 15) %>% as.integer(),
        duplicated_rows = duplicated_rows,
        duplicated_rows_num = duplicated_rows_num,
        num_of_rows = num_of_rows
    )

    if (duplicated_rows_num > 0) {
        summary_duplicated_dataframe <- summary_duplicated_dataframe %>% add_row(
            filename = filename_no_ext,
            normal_record = num_of_rows - duplicated_rows_num,
            duplicated_record = duplicated_rows_num
        )
    }

    # saveRDS(df, file.path(path_to_output_dir, filename))
}

source(file.path(getwd(), "utilities.R"))

p <- summary_duplicated_dataframe %>%
    pivot_longer(cols = ends_with("record"), names_to = "record") %>%
    ggplot(aes(fill=record, y=value, x=filename)) +
    geom_bar(position="stack", stat="identity") +
    labs(
        title = "資料異常重複列數",
        x = "檔案名稱",
        y = "資料筆數",
        fill = "異常資料筆數"
    ) + scale_fill_discrete(
        breaks = c("duplicated_record", "normal_record"),
        labels = c("重複資料", "正常記錄資料")
    )

save_ggplot2_plot(p, "duplicated_rows_stat.png")

