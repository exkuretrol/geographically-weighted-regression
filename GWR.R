# dependency ----
# Data manipulation, transformation and visualisation
library(tidyverse)
# Nice tables
library(kableExtra)
# Simple features (a standardised way to encode vector data ie. points, lines, polygons)
library(sf)
# Spatial objects conversion
library(sp)
# Thematic maps
library(tmap)
# Colour palettes
library(RColorBrewer)
# More colour palettes
library(viridis) # nice colour schemes
# Fitting geographically weighted regression models
library(spgwr)
# Obtain correlation coefficients
library(corrplot)
# Exportable regression tables
library(jtools)
library(stargazer)
library(sjPlot)
# Assess multicollinearity
library(car)

# data ----
# clean workspace
rm(list = ls())
# read data
utla_shp <- st_read("data/gwr/Covid19_total_cases_geo.shp") %>%
  select(objct, cty19c, ctyu19nm, long, lat, st_rs, st_ln, X2020.04.14, I.PL1, IMD20, IMD2., Rsdnt, Hshld, Dwlln, Hsh_S, E_16_, A_65_, Ag_85, Mixed, Indin, Pkstn, Bngld, Chins, Oth_A, Black, Othr_t, CB_U_, Crwd_, Lng__, Trn__, Adm__, Ac___, Pb___, Edctn, H____, geometry)

# replace nas with 0s
# utla_shp[is.na(utla_shp)] <- 0
utla_shp %>%
  is.na() %>%
  table()

# explore data
str(utla_shp)

# exploratory analysis ----
# risk of covid-19 infection
utla_shp$covid19_r <- (utla_shp$X2020.04.14 / utla_shp$Rsdnt) * 100000

# histogram
ggplot(data = utla_shp) +
  geom_density(alpha = 0.8, colour = "black", fill = "lightblue", aes(x = covid19_r)) +
  theme_classic()

summary(utla_shp$covid19_r)

# read region boundaries for a better looking map
reg_shp <- st_read("data/gwr/Regions_December_2019_Boundaries_EN_BGC.shp")


# ensure geometry is valid
utla_shp <- sf::st_make_valid(utla_shp)
reg_shp <- sf::st_make_valid(reg_shp)

# map
legend_title <- expression("Cumulative cases per 100,000")
map_utla <- tm_shape(utla_shp) +
  tm_fill(col = "covid19_r", title = legend_title, palette = magma(256), style = "cont") + # add fill
  tm_borders(col = "white", lwd = .1) + # add borders
  tm_compass(type = "arrow", position = c("right", "top"), size = 5) + # add compass
  tm_scale_bar(breaks = c(0, 1, 2), text.size = 0.7, position = c("center", "bottom")) + # add scale bar
  tm_layout(bg.color = "white") # change background colour
map_utla + tm_shape(reg_shp) + # add region boundaries
  tm_borders(col = "white", lwd = .5) # add borders

utla_shp %>%
  select(ctyu19nm, covid19_r) %>%
  filter(covid19_r > 190) %>%
  arrange(desc(covid19_r))

# define predictors
utla_shp <- utla_shp %>% mutate(
  crowded_hou = Crwd_ / Hshld, # share of crowded housing
  elderly = (A_65_ + Ag_85) / Rsdnt, # share of population aged 65+
  lt_illness = Lng__ / Rsdnt, # share of population in long-term illness
  ethnic = (Mixed + Indin + Pkstn + Bngld + Chins + Oth_A + Black + Othr_t) / Rsdnt, # share of nonwhite population
  imd19_ext = IMD20, # proportion of a larger area’s population living in the most deprived LSOAs in the country
  hlthsoc_sec = H____ / E_16_, # share of workforce in the human health & social work sector
  educ_sec = Edctn / E_16_, # share of workforce in the education sector
  trnsp_sec = Trn__ / E_16_, # share of workforce in the Transport & storage sector
  accfood_sec = Ac___ / E_16_, # share of workforce in the accommodation & food service sector
  admsupport_sec = Adm__ / E_16_, # share of workforce in the administrative & support sector
  pblic_sec = Pb___ / E_16_ # share of workforce in the public administration & defence sector
)

# obtain a matrix of Pearson correlation coefficients
df_sel <- st_set_geometry(utla_shp[, 37:48], NULL) # temporary data set removing geometries
cormat <- cor(df_sel, use = "complete.obs", method = "pearson")

# significance test
sig1 <- corrplot::cor.mtest(df_sel, conf.level = .95)

# creta a correlogram
corrplot::corrplot(cormat,
  type = "lower",
  method = "circle",
  order = "original",
  tl.cex = 0.7,
  p.mat = sig1$p, sig.level = .05,
  col = viridis::viridis(100, option = "plasma"),
  diag = FALSE
)
