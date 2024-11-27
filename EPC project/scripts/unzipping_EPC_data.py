'''
This script is for initially unzipping the EPC data and saving the relevant data as csv files 
in the current folder. 
'''

import pandas as pd
import re
import zipfile


#opening the Manchester EPC data zip file
print("\nUnzipping the Manchester EPC data and saving it.\n")
with zipfile.ZipFile('domestic-E08000003-Manchester.zip') as z:
    # print a list of the names of the files in that folder
    print(z.namelist()) 
    # read in 2 of the files to have a look at
    with z.open('certificates.csv') as file:
        manchester_epc = pd.read_csv(file)  
    with z.open('recommendations.csv') as file:
        manchester_recs= pd.read_csv(file) 

#save the Manchester EPC data as a csv file to access later.
manchester_epc.to_csv('manchester_epc.csv')
print(manchester_epc.head())


#opening the Scottish EPC data zipfile
print("Unzipping the Scottish EPC data and saving it.\n")
with zipfile.ZipFile('D_EPC_data_2014-2024Q3.zip') as z:
#joining all the seperate csv files for each seperate quarter of a year into one dataframe
    #creating a list of all the files we want from the folder
    csv_files = [f for f in z.namelist() if re.fullmatch(r'[0-9]{4}Q[1-4].csv', f)] 

    to_concat = []
    
    for f in csv_files:
        with z.open(f) as file:

            # print(f'Loading file {f}.')
            df_ = pd.read_csv(file, skiprows=[1]) #skipping row 1 which is a description of the headers
            to_concat.append(df_)
            
    scotland_epc = pd.concat(to_concat) #creating a big data frame of all the individual data frames

#save the data frame of scottish EPC data as a csv file 
scotland_epc.to_csv('scotland_epc.csv')
print(scotland_epc.head())


# Getting the postcode to LSOA data (Lower Layer Super Output Areas - equivelant to data zones in Scotland)
print("Unzipping the postcode to LSOA data and saving it.\n")
with zipfile.ZipFile('NSPL_2011_AUG_2024.zip') as z:
    with z.open('Data/NSPL_AUG_2024_UK.csv') as file:
         #only selecting the 2 relevent columns from the data set
         pcd_to_lsoa = pd.read_csv(file, usecols=['pcds', 'lsoa11'])

#changing the column names:
pcd_to_lsoa.rename(columns={'pcds': 'POSTCODE', 'lsoa11': 'LSOA_CODE'}, inplace=True)

#save the data frame of the postcode to lsoa as a csv file 
pcd_to_lsoa.to_csv('pcd_to_lsoa.csv')
print(pcd_to_lsoa.head())