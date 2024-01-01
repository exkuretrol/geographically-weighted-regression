library(readr)
metadata <- read_csv("air_quality/site_metadata/空氣品質監測站基本資料.csv")

metadata %>% 
    head

metadata <- colnames(metadata) %>% 
    gsub(
        pattern = "\"", 
        replacement = ""
    ) %>% 
    `colnames<-`(metadata, .)

# saveRDS(metadata, "./air_quality/site_metadata/metadata.RDS")
