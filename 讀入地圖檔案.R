# site: https://whgis-nlsc.moi.gov.tw/Opendata/Files.aspx

# 下載解壓縮資料

# 鄉鎮市區界線(TWD97經緯度)
town_url <- "https://whgis.nlsc.gov.tw/DownlaodFiles.ashx?oid=1338&path=Opendata/OpendataFiles/OFiles_ae756a66-701c-4eb1-bb96-3951c16404df.zip"

# 村(里)界(TWD97經緯度)
village_url <- "https://whgis.nlsc.gov.tw/DownlaodFiles.ashx?oid=1337&path=Opendata/OpendataFiles/OFiles_bf4d195f-134d-4e6e-b6ac-b3f03010be25.zip"

# 直轄市、縣市界線(TWD97經緯度)1090820
county_url <- "https://whgis-nlsc.moi.gov.tw/DownlaodFiles.ashx?oid=1012&path=Opendata/OpendataFiles/OFiles_6a8c4a45-1787-4e97-96a4-91f871e96b63.zip"


town_file <- tempfile()
village_file <- tempfile()
county_file <- tempfile()

gwr_files <- file.path(getwd(), "geo")
if (!dir.exists(gwr_files)) dir.create(gwr_files)

download.file(url = town_url, destfile = town_file)
download.file(url = village_url, destfile = village_file)
download.file(url = county_url, destfile = county_file)
unzip(zipfile = town_file, exdir = gwr_files)
unzip(zipfile = village_file, exdir = gwr_files)
unzip(zipfile = county_file, exdir = gwr_files)

# system("ls -ali ./Data_GWR", intern = TRUE)
# system("find ./Data_GWR -inum 4989212 -exec rm {} \\;")

library(sf)
town <- sf::read_sf("Data_GWR/TOWN_MOI_1120317.shp")
plot(town)

village <- sf::read_sf("Data_GWR/VILLAGE_NLSC_1120317.shp")

county <- sf::read_sf("Data_GWR/COUNTY_MOI_1090820.shp")
county

county %>% 
    filter(!(COUNTYID %in% c("W", "Z", "X"))) %>% 
    select(geometry) %>% 
    plot()


# aqx <- readRDS(file = "./air_quality/aqx_p_13_RDS_T_daily/aqx_p_13_202212.RDS")
# aqx

aqx_dec_1 <- aqx %>% filter(monitordate == lubridate::as_date("2022-12-01"))

station_info <- readr::read_csv("空氣品質監測站基本資料.csv")
station_columns <- station_info %>% 
    colnames() %>% 
    sapply(., \(x) gsub(pattern = "\"", replacement = "", x = x)) %>% 
    unname()

colnames(station_info) <- station_columns
station_info_lonlat <- station_info %>% 
    select(twd97lon, twd97lat, siteid)

aqx_dec_1_xy <- left_join(aqx_dec_1, station_info_lonlat, by = "siteid")

north_region <- county %>% 
    filter(COUNTYNAME %in% c("臺北市", "新北市", "基隆市", "桃園市"), TOWNID != "C01") 

library(ggplot2)

county_data <- left_join(aqx_dec_1_xy, north_region, by = c())

ggplot()