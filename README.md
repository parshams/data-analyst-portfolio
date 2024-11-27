# data-analyst-portfolio
"A portfolio showcasing my data analysis skills using Python, SQL, and R."

# EPC project

This project explores EPC ratings (Energy Performance Certificate) in the UK using open data from Scotland and Manchester. 

---

## Project Overview
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
- **Objective:** Join EPC data from various regions across the UK, conduct statistical analysis, and generate visuals to interpret the findings.
- **Key Steps:**
  1. Data cleaning and preprocessing
  2. Exploratory data analysis (EDA)
  3. Feature engineering
  4. Statistical analysis
  5. Generate visuals

---

## Contents
- **`data/`** contains samples of data that has been cleaned/ processed
  - **`joined_epc_data_sample`** a sample of the cleaned and joined EPC data from Scotland and Manchester
- **`scripts/`** 
  - **`unzipping_EPC_data.py`:** Python script which unpacks the downloaded files and saves them
  - **`cleaning_EPC_data.py`:** Python script which cleans and joins the Scottish and Manchester data sets
  - **`EPC_visual_map.r`:** R script which creates an interactive map of Scottish energy efficiency gap per LSOA
- **`visuals/`** 
  - **`scot_energy_gap_by_lsoa.html`:** Interactive map of Scotland showcasing the energy efficiency gap per LSOA
---

## Key Insights
- Properties in rural areas of Scotland tend to have lower energy efficiency compared to those in cities. However, they show greater potential for improvement, particularly through measures such as installing high-performance glazing on windows.
- Newer built properties have better energy efficiency than properties built before 1900.

---

## Next Steps
- Incorporate additional data to create a model predicting fuel poverty based on SIMD, EPC data and property data.  

---
