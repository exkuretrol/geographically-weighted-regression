library(tidyverse)
library(stringr)
library(httr)
library(jsonlite)
library(readr)
dotenv::load_dot_env()

# aqx_p_138 每小時提供桃園市空品監測資料小時值。不過他壞掉了
# aqx_p_13
dataset <- "aqx_p_13"

# API format ----
base_url <- "https://data.epa.gov.tw"
# 平臺提供格式包含JSON、 XML、 CSV，請依欲下載資料格式自行更換。
# filter
generate_filter <- function(sitename = c("中壢", "龍潭", "平鎮", "觀音", "大園", "桃園"), year = 2021, month = 1) {
    year <- toString(year)
    month <- sprintf("%02d", month)
    last_day_of_month <- str_interp("${year}-${month}-01") %>%
        lubridate::as_date() %>%
        lubridate::ceiling_date(., unit = "month") - lubridate::days(1)
    if (length(sitename) > 1) sitename <- paste0(sitename, collapse = ",")
    filter <- c(
        "sitename,EQ,${sitename}",
        "monitordate,GR,${year}-${month}-01",
        "monitordate,LE,${last_day_of_month}"
    ) %>%
        paste0(., collapse = "|") %>%
        str_interp()

    return(filter)
}

generate_empty_dataframe <- function() {
    df <- c(
        "siteid",
        "sitename",
        "itemid",
        "itemname",
        "itemengname",
        "itemunit",
        "monitordate",
        sprintf("%02d", 0:23) %>% paste0("monitorvalue", .)
    ) %>%
        paste(collapse = ",") %>%
        I() %>%
        readr::read_csv(
            col_types = rep("d", 24) %>% paste0(collapse = "") %>% paste0("icicccD", .)
        )
    return(df)
}

# 設定儲存目錄
output_dir <- paste("air_quality/", dataset, "_RDS", sep = "")
if (!(dir.exists(output_dir))) dir.create(output_dir, recursive = TRUE)

fetch_data <- function(years = 2021:2022, months = 1:12) {
    for (year in years)
    {
        for (month in months)
        {
            # reset at start of loop
            offset <- 0
            df <- generate_empty_dataframe()

            message("processing ${year}.${month} data..." %>% str_interp())
            while (TRUE) {
                
                message("fetching data from API...\t", appendLF = FALSE)
                res <- GET(
                    url = base_url,
                    path = "/api/v2/${dataset}" %>% str_interp(),
                    query = list(
                        # 格式
                        format = "json",
                        # 為遞移起始下載筆數使用，請輸入欲跳過的筆數
                        offset = offset,
                        # 請輸入欲取得資料的筆數，資料擷取上限為1000筆
                        limit = 1000,
                        # 篩選條件
                        filters = generate_filter(
                            year = year,
                            month = month
                        ) %>% I(),
                        # 加入會員後可取得api_key，請自行更換。
                        api_key = Sys.getenv("api_key")
                    )
                )
                # sleep a while
                Sys.sleep(1)

                # processing json
                resText <- content(res, as = "text", encoding = "utf-8")
                json <- fromJSON(resText)

                # break loop if get nothing
                if (!json$records %>% is.data.frame()) 
                {
                    message("end of records, stop fetching data.")
                    break
                }

                # add records
                f <- tempfile()
                json$records %>% 
                    # fix siteid is double??
                    mutate(
                        siteid = as.integer(siteid),
                        itemid = as.integer(itemid)
                    ) %>% 
                    write_csv(file = f)
                

                df <- readr::read_csv(
                    file = f,
                    col_types = rep("d", 24) %>% paste0(collapse = "") %>% paste0("icicccD", .),
                    na = c("x", "")
                ) %>% 
                    rbind(., df)
                
                # offset++
                offset <- offset + 1000
                message("done")
            }

            message("writing dataframe to RDS")
            
            df <- df %>% 
                arrange(monitordate, siteid, itemid)
            saveRDS(df, file = file.path(getwd(), output_dir, str_interp("apx_p_13_${year}-${month}.RDS")))
        }
    }
}

tryCatch(
    {
        fetch_data(years = 2020, months = 1:12)
    },
    warning = function(x) {
        problems()
        stop("converted from warning: \n", conditionMessage(x))
    }
)
