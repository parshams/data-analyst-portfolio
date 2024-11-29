-- A selection of queries for the joined epc data frame  
-- containing Scottish and Manchester EPC data


-- Percentage of null values in local authority column 
SELECT 
    100.0 * COUNT(*) FILTER (WHERE LOCAL_AUTHORITY_LABEL IS NULL) / COUNT(*) AS LA_percentage_null
FROM epc_data_v2;
-- = 8.6%


-- Comparing energy rating and energy consumption
SELECT 
    CURRENT_ENERGY_RATING,
    ROUND(AVG(ENERGY_CONSUMPTION_CURRENT)) AS avg_energy_consumption
FROM epc_data_v2
GROUP BY CURRENT_ENERGY_RATING
ORDER BY CURRENT_ENERGY_RATING;


-- Percentage of epc ratings D-F (below average) per each local authority
SELECT 
    LOCAL_AUTHORITY_LABEL, 
    ROUND((COUNT(CASE WHEN CURRENT_ENERGY_RATING IN ('D', 'E', 'F') THEN 1 END) * 100.0 / COUNT(*)) ,2) AS PERC_EPC_RATING_D_OR_LOWER
FROM epc_data_v2
GROUP BY LOCAL_AUTHORITY_LABEL
ORDER BY PERC_EPC_RATING_D_OR_LOWER DESC;



-- Best areas (LSOAs) to target for biggest potential energy efficiency increase
-- and environmental impact decrease
SELECT 
    LSOA_CODE,
    ROUND(AVG(ENERGY_EFFICIENCY_GAP),2) AS AVG_ENERGY_EFFICIENCY_GAP,
    ROUND(AVG(ENVIRONMENT_IMPACT_GAP),2) AS AVG_ENVIRONMENTAL_IMPACT_GAP 
FROM epc_data_v2
GROUP BY LSOA_CODE
ORDER BY AVG_ENERGY_EFFICIENCY_GAP DESC, AVG_ENVIRONMENTAL_IMPACT_GAP DESC;



-- Percentage of missing data in the construction age column
-- for each LSOA, ranked by percentage missing 
SELECT 
    LSOA_CODE,
    COUNT(*) AS lsoa_total_count,
    SUM(
        CASE 
            WHEN CONSTRUCTION_AGE_BAND IS NULL 
            THEN 1 
            ELSE 0 
        END
    ) AS missing_property_age_count,
    ROUND(
        100.0 * SUM(
            CASE 
                WHEN CONSTRUCTION_AGE_BAND IS NULL 
                THEN 1 
                ELSE 0 
            END
        ) / COUNT(*), 2
    ) AS percentage_missing
FROM 
    epc_data_v2
GROUP BY 
    LSOA_CODE
ORDER BY 
    percentage_missing DESC;



-- identifying top performing LSOAs and comparing them to the average property in Scotland

WITH BestPerforming AS (
    SELECT *
    FROM epc_data_v2
    WHERE ENERGY_CONSUMPTION_CURRENT < (SELECT PERCENTILE_CONT(0.3) WITHIN GROUP (ORDER BY ENERGY_CONSUMPTION_CURRENT) FROM epc_data_v2)
      AND CURRENT_ENERGY_EFFICIENCY > (SELECT PERCENTILE_CONT(0.7) WITHIN GROUP (ORDER BY CURRENT_ENERGY_EFFICIENCY) FROM epc_data_v2)
      AND ENVIRONMENT_IMPACT_CURRENT < (SELECT PERCENTILE_CONT(0.3) WITHIN GROUP (ORDER BY ENVIRONMENT_IMPACT_CURRENT) FROM epc_data_v2)
)

SELECT 
    'All Properties' AS group_name,
    NULL AS LSOA_CODE,
    ROUND(AVG(ENERGY_CONSUMPTION_CURRENT)) AS avg_energy_consumption,
    ROUND(AVG(CURRENT_ENERGY_EFFICIENCY)) AS avg_energy_efficiency,
    ROUND(AVG(ENVIRONMENT_IMPACT_CURRENT),2) AS avg_environment_impact,
    ROUND(AVG(TOTAL_FLOOR_AREA)) AS avg_floor_area
FROM 
    epc_data_v2
WHERE LSOA_CODE LIKE 'S%' --Scottish codes only

UNION ALL

SELECT 
    'Best Performing' AS group_name,
    LSOA_CODE,
    AVG(ENERGY_CONSUMPTION_CURRENT) AS avg_energy_consumption,
    ROUND(AVG(CURRENT_ENERGY_EFFICIENCY)) AS avg_energy_efficiency,
    ROUND(AVG(ENVIRONMENT_IMPACT_CURRENT)) AS avg_environment_impact,
    AVG(TOTAL_FLOOR_AREA) AS avg_floor_area
FROM 
    BestPerforming
WHERE LSOA_CODE LIKE 'S%' --Scottish codes only
GROUP BY LSOA_CODE;




-- Comparing energy consumption, efficiency and floor area 
-- between scotland, manchester, edinburgh, glasgow
SELECT 
    'Scotland' AS PLACE,
    ROUND(AVG(TOTAL_FLOOR_AREA)) AS avg_floor_area,
    ROUND(AVG(ENERGY_CONSUMPTION_CURRENT)) AS avg_energy_consumption,
    ROUND(AVG(CURRENT_ENERGY_EFFICIENCY)) AS avg_energy_efficiency
FROM epc_data_v2
WHERE LSOA_CODE LIKE 'S%'

UNION ALL

SELECT 
    'Manchester' AS PLACE,
    ROUND(AVG(TOTAL_FLOOR_AREA)) AS avg_floor_area,
    ROUND(AVG(ENERGY_CONSUMPTION_CURRENT)) AS avg_energy_consumption,
    ROUND(AVG(CURRENT_ENERGY_EFFICIENCY)) AS avg_energy_efficiency
FROM epc_data_v2
WHERE LOCAL_AUTHORITY_LABEL = 'Manchester'

UNION ALL

SELECT 
    'Edinburgh' AS PLACE,
    ROUND(AVG(TOTAL_FLOOR_AREA)) AS avg_floor_area,
    ROUND(AVG(ENERGY_CONSUMPTION_CURRENT)) AS avg_energy_consumption,
    ROUND(AVG(CURRENT_ENERGY_EFFICIENCY)) AS avg_energy_efficiency
FROM epc_data_v2
WHERE LOCAL_AUTHORITY_LABEL = 'Edinburgh City'

UNION ALL

SELECT 
    'Glasgow' AS PLACE,
    ROUND(AVG(TOTAL_FLOOR_AREA)) AS avg_floor_area,
    ROUND(AVG(ENERGY_CONSUMPTION_CURRENT)) AS avg_energy_consumption,
    ROUND(AVG(CURRENT_ENERGY_EFFICIENCY)) AS avg_energy_efficiency
FROM epc_data_v2
WHERE LOCAL_AUTHORITY_LABEL = 'Glasgow City';



-- Comparing energy efficiency for different window glazings
SELECT
    WINDOWS_DESCRIPTION,
    ROUND(AVG(CURRENT_ENERGY_EFFICIENCY)) AS avg_energy_efficiency,
    ROUND(AVG(ENERGY_CONSUMPTION_CURRENT)) AS avg_energy_consumption
FROM epc_data_v2
GROUP BY WINDOWS_DESCRIPTION
ORDER BY avg_energy_consumption DESC;



-- Comparing energy consumption and environmental impact per construction age
SELECT 
    CONSTRUCTION_AGE_BAND,
    ROUND(AVG(ENERGY_CONSUMPTION_CURRENT)) AS avg_energy_consumption,
    ROUND(AVG(ENVIRONMENT_IMPACT_CURRENT)) AS avg_environment_impact
FROM epc_data_v2
GROUP BY CONSTRUCTION_AGE_BAND;