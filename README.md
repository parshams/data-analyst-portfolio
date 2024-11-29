# data-analyst-portfolio
"A portfolio showcasing my data analysis skills using Python, SQL, and R."

# EPC project

This project explores EPC ratings (Energy Performance Certificate) in the UK using open data from Scotland and Manchester. 

---

## Project Overview
- **Objective:** Join EPC data from various regions across the UK, conduct statistical analysis, and generate visuals to interpret the findings.
  
- **Key Steps:**
  1. Data collection, extraction and anonymisation
  2. Data cleaning and preprocessing
  3. Data joining, ensuring consistency
  4. Exploratory data analysis (EDA) and statistical analysis
  5. Data visualisation and insights communication
     
- **Data Sources:**
  - Scotland EPC data
    https://statistics.gov.scot/data/domestic-energy-performance-certificates
  - England & Wales EPC data
    https://epc.opendatacommunities.org/domestic/search?address=&postcode=&local-authority=E08000003&constituency=&uprn=&from-month=1&from-year=2008&to-month=12&to-year=2024
  - Postcode to LSOA (Lower layer Super Output Area) lookup table
    https://geoportal.statistics.gov.uk/datasets/c5afedb9204a47e99559a4880feddcb1/about
  - Scottish geospatial data
    https://spatialdata.gov.scot/geonetwork/srv/eng/catalog.search#/metadata/7d3e8709-98fa-4d71-867c-d5c8293823f2
  - England & Wales geospatial data
    https://geoportal.statistics.gov.uk/datasets/ons::lower-layer-super-output-areas-december-2011-boundaries-ew-bfc-v3/about

---

## Contents
- **`data/`** contains samples of data that has been cleaned/ processed
  - **`joined_epc_data_sample`** a sample of the cleaned and joined EPC data from Scotland and Manchester
- **`scripts/`** 
  - **`unzipping_EPC_data.py`:** Python script which unpacks the downloaded files and saves them as csv files
  - **`cleaning_EPC_data.py`:** Python script which cleans and joins the Scottish and Manchester EPC data sets
  - **`EPC_visual_map.r`:** R script which creates an interactive map of Scottish energy efficiency gap (current - potential energy efficiency) per LSOA
  - **`epc_joined_data_queries.sql`** PostgreSQL queries on the joined EPC data
  - **`EPC_plots.r`:** R script performing statistical analysis and producing plots
- **`visuals/`** 
  - **`scot_energy_gap_by_lsoa.html`:** Interactive map of Scotland showcasing the energy efficiency gap per LSOA.
  - **`energy_cor_heatmap`:** Heatmap showcasing the correlation between various energy variables
  - **`energy_scatter_plot`:** Scatterplot of Energy Efficiency vs Energy Consumption after removing outliers from Energy Consumption data
  - **`energy_use_by_property_boxplot`:** Boxplot of energy consumption for various property types
    
  NOTE ON THE MAP: You must download the file (`scot_energy_gap_by_lsoa.html`) and the accompanying folder to be able to view it as an interactive map in your browser.
  Some still images of the map have also been included.
    
---

## Key Insights
- Houses in rural areas of Scotland tend to have lower energy efficiency compared to those in cities. However, they show greater potential for improvement.
- Properties with higher energy efficiency ratings (A or B) have significantly lower energy consumption compared to those rated E or below.
- Older properties (built before 2000) tend to have higher energy consumption and lower environmental impact ratings than newer built properties.
- The average floor area for properties in Scotland is larger than in Manchester, potentially explaining higher energy usage in Scottish properties.
- Properties with mixed or single glazed windows show a correlation with higher energy consumption and lower energy efficiency compared with double, triple or high performance glazing.
  
---

## Next Steps
- Scale up the project to include data from the entirety of England & Wales, building upon data processing of Manchester.
- Incorporate additional data to create a model predicting fuel poverty based on SIMD, EPC data and property data.  

---
