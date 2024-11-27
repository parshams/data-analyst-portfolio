
# This script creates a map of the average energy efficiency gap
# (the current energy efficiency - potential energy efficiency)
# for each LSOA (Lower Layer Super Output Area).

# This script could be modified to display other variables in the epc data set.


install.packages(c("sf", "ggplot2", "dplyr", "tmap"))
library(sf)
library(ggplot2)
library(dplyr)
library(tmap)

scot_zip_file <- "SG_DataZoneBdry_2011.zip"
unzip(scot_zip_file, list = TRUE)
scot_lsoa_boundary <- st_read("SG_DataZone_Bdry_2011.shp")

# change name of datazone column in scottish data to lsoa11cd as in the english dataset
scot_lsoa_boundary <- scot_lsoa_boundary %>% rename(LSOA11CD = DataZone)

epc_data <- read.csv("joined_epc_data.csv")

# aggregate data to visualise on map
# could change this to another variable
epc_summary <- epc_data %>%
  group_by(LSOA_CODE) %>%
  summarise(avg_energy_efficiency_gap = round(mean(ENERGY_EFFICIENCY_GAP, na.rm = TRUE), 2))

# making a map of scotland   
scot_lsoa_map <- scot_lsoa_boundary %>%
  left_join(epc_summary, by = c("LSOA11CD" = "LSOA_CODE"))

tmap_mode("view") # interactive view
tmap_options(check.and.fix = TRUE) # allows interactive view for invalid polygons

tm_shape(scot_lsoa_map) +
  tm_polygons("avg_energy_efficiency_gap", 
              style = "quantile", 
              palette = "viridis", 
              title = "Avg Energy Efficiency Gap") +
  tm_layout(title = "Scottish Energy Gap by LSOA")

# Save as an interactive HTML map
tmap_save(filename = "scot_energy_gap_by_lsoa.html")

