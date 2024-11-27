'''
This script comes after the unzipping_EPC_data script.

This is an example of joining together data from different regions,
where I have to make sure data entry is consistent between the data sets. 

This project could be scaled up to use data from all of England and Wales,
I just selected one city (Manchester) as the data set was huge. 

This script downloads the EPC data from all of Scotland and Manchester, selects desired columns, 
cleans the data and joins the two data sets together, ensuring consistent data entry. 

I am using real world data from the government and the Office for National Statistics 
in order to match postcodes with geographic location markers (LSOAs).

'''

import pandas as pd
import re

SCOT_EPC_LOC = 'scotland_epc.csv'
SCOT_EPC_INPUT_COLS = [
    'POSTCODE', 'DATA_ZONE', 'LOCAL_AUTHORITY_LABEL', 
    'ENERGY_CONSUMPTION_CURRENT', 'ENERGY_CONSUMPTION_POTENTIAL', 
    'CURRENT_ENERGY_RATING', 'POTENTIAL_ENERGY_RATING',
    'CURRENT_ENERGY_EFFICIENCY', 'POTENTIAL_ENERGY_EFFICIENCY', 
    'ENVIRONMENT_IMPACT_CURRENT', 'ENVIRONMENT_IMPACT_POTENTIAL',
    'TOTAL_FLOOR_AREA', 'WINDOWS_DESCRIPTION','CONSTRUCTION_AGE_BAND', 'TENURE',
    'BUILT_FORM', 'PROPERTY_TYPE'
]

ENG_EPC_LOC = 'manchester_epc.csv'
ENG_EPC_INPUT_COLS = [ 
    'POSTCODE', 'LOCAL_AUTHORITY_LABEL',
    'ENERGY_CONSUMPTION_CURRENT', 'ENERGY_CONSUMPTION_POTENTIAL',
    'CURRENT_ENERGY_RATING', 'POTENTIAL_ENERGY_RATING',
    'CURRENT_ENERGY_EFFICIENCY', 'POTENTIAL_ENERGY_EFFICIENCY',
    'ENVIRONMENT_IMPACT_CURRENT', 'ENVIRONMENT_IMPACT_POTENTIAL',
    'TOTAL_FLOOR_AREA', 'WINDOWS_DESCRIPTION', 'CONSTRUCTION_AGE_BAND',
    'TENURE', 'BUILT_FORM', 'PROPERTY_TYPE'
]

scot_epc = pd.read_csv(SCOT_EPC_LOC, usecols=SCOT_EPC_INPUT_COLS)
scot_epc = scot_epc[SCOT_EPC_INPUT_COLS] # reorder columns

scot_epc["DATA_ZONE"] = scot_epc["DATA_ZONE"].str.extract(r'^(S\d+)\s\(.+\)$')

manch_epc = pd.read_csv(ENG_EPC_LOC, usecols=ENG_EPC_INPUT_COLS)
manch_epc = manch_epc[ENG_EPC_INPUT_COLS] # reorder columns

# replacing the postcode column in the manchester dataset with the LSOA codes 
# note Scottish 'data zones' are equivalent to England & Wales 'LSOAs' (Lower Layer Super Output Areas)
pcd_to_lsoa = pd.read_csv('pcd_to_lsoa.csv', usecols=['POSTCODE','LSOA_CODE'])

manch_epc = manch_epc.merge(pcd_to_lsoa, on='POSTCODE', how='left')

prop_missing = manch_epc.LSOA_CODE.isna().mean()
assert prop_missing < 0.01, f'{prop_missing:.2%} of postcodes do not match to an LSOA.'

# dropping rows with no LSOA code
manch_epc = manch_epc[~manch_epc.LSOA_CODE.isna()]
manch_epc = manch_epc.drop(columns='POSTCODE')

# fill any empty data zone values in the scottish data using the postcodes
scot_epc = scot_epc.merge(pcd_to_lsoa, on='POSTCODE', how = 'left')
prop_missing = scot_epc.LSOA_CODE.isna().mean()
assert prop_missing < 0.01, f'{prop_missing:.2%} of scottish postcodes do not match to an LSOA.'
scot_epc = scot_epc[~scot_epc.LSOA_CODE.isna()]

# datazones in scottish epc data are not equal to the national statistics lookup table lsoa codes.
# we'll use the lsoa codes to be consistent between scotland and england & wales
scot_epc = scot_epc.drop(columns=['POSTCODE', 'DATA_ZONE'])

# Joining the Scottish and Manchester data sets together
assert set(scot_epc.columns) == set(manch_epc.columns)
joined_data = pd.concat([scot_epc, manch_epc], ignore_index=True)
joined_data.insert(0, 'LSOA_CODE', joined_data.pop('LSOA_CODE'))

# Cleaning up the WINDOWS_DESCRIPTION column

joined_data['WINDOWS_DESCRIPTION'] = (
    joined_data['WINDOWS_DESCRIPTION']
    .str.strip().str.lower()
    .str.replace('description: ','')
    .str.replace('glazed','glazing')
    .str.replace('fully','full')
    .str.replace('partial','multiple')
    .str.replace('mostly','multiple')
    .str.replace('some','multiple')
)

joined_data.loc[joined_data['WINDOWS_DESCRIPTION'].str.contains('multiple').fillna(False), 'WINDOWS_DESCRIPTION'] = 'mixed glazing'

WINDOW_TYPES = [
    'full double glazing', 
    'high performance glazing', 
    'mixed glazing',
    'single glazing',
    'full triple glazing',
    'full secondary glazing'
]

joined_data['WINDOWS_DESCRIPTION'] = (
    joined_data['WINDOWS_DESCRIPTION']
    .where(
        joined_data['WINDOWS_DESCRIPTION'].isin(WINDOW_TYPES),
        other='other'
    )
)

# Cleaning up the TENURE column 

joined_data['TENURE'] = (
    joined_data['TENURE']
    .str.strip().str.lower()
    .str.replace('rental','rented')
)

TENURE_TYPES = [
    'rented (social)',
    'owner-occupied',
    'rented (private)'
]

joined_data['TENURE'] = (
    joined_data['TENURE']
    .where(
        joined_data['TENURE'].isin(TENURE_TYPES),
        other='unknown'
    )
)

# Cleaning up the CONSTRUCTION_AGE_BAND column 

joined_data['CONSTRUCTION_AGE_BAND'] = (
    joined_data['CONSTRUCTION_AGE_BAND']
    .str.strip().str.lower()
    .str.replace('england and wales: ','')
    .str.replace('no data!', 'unknown')
    .str.replace('invalid!', 'unknown')
)

pattern = r'\b(200[7-9]|20[1-9][0-9])\b'
matches = joined_data["CONSTRUCTION_AGE_BAND"].str.contains(pattern, regex=True).fillna(False)
joined_data.loc[matches, "CONSTRUCTION_AGE_BAND"] = "2007 onwards"

solo_years = joined_data["CONSTRUCTION_AGE_BAND"].str.contains(r"^\d{4}$", regex=True).fillna(False)
joined_data.loc[solo_years, "CONSTRUCTION_AGE_BAND"] = "unknown"

#New feature creation: difference between the actual and potential energy consumption, energy efficiency, and environmental impact. 
joined_data['ENERGY_CONSUMPTION_GAP'] = joined_data['ENERGY_CONSUMPTION_CURRENT'] - joined_data['ENERGY_CONSUMPTION_POTENTIAL']
joined_data['ENERGY_EFFICIENCY_GAP'] = joined_data['POTENTIAL_ENERGY_EFFICIENCY'] - joined_data['CURRENT_ENERGY_EFFICIENCY']
joined_data['ENVIRONMENT_IMPACT_GAP'] = joined_data['ENVIRONMENT_IMPACT_POTENTIAL'] - joined_data['ENVIRONMENT_IMPACT_CURRENT']

# saving the data frame to a csv in this folder to be used elsewhere
joined_data.to_csv('joined_epc_data.csv', index=False)