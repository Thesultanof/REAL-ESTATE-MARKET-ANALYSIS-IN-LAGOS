ALTER TABLE dwellers_tenants
RENAME COLUMN `Budget(Maximum)`
TO Max_budget;

#NUMBER 1
#What is the average rent across Lagos by property type and location?
SELECT location,property_type,AVG(monthly_rent)Average_Monthly_rent 
FROM dwellers_listings
GROUP BY Location,Property_Type
ORDER BY Location ;

#NUMBER 2
#Which locations have the highest ratio of rent to number of bedrooms?
SELECT LOCATION,
CONCAT(SUM(MONTHLY_RENT)/SUM(BEDROOMS)," ","PER_ROOM")RATIO_PER_ROOM
FROM dwellers_listings
GROUP BY LOCATION
ORDER BY RATIO_PER_ROOM DESC;

#3
#How many listings go stale (never interacted with after 30 days)?
WITH CTE AS 
(SELECT distinct DL.LISTING_ID,
datediff(DATE_LISTED,ACTION_DATE)INTERACTION_DAYS
FROM dwellers_listings DL
JOIN dwellers_interactions DI
ON DL.Listing_ID = DI.Listing_ID
GROUP BY LISTING_ID,INTERACTION_DAYS
HAVING INTERACTION_DAYS <30
ORDER BY DL.LISTING_ID )
SELECT concat(COUNT(DISTINCT(LISTING_ID))," ","Properties")NO_OF_STALE_LISTING
FROM CTE
;



#4
#Which age groups search the most vs apply the most?
SELECT AGE_GROUP,
COUNT(DISTINCT(Tenant_ID))SEARCHERS,
 COUNT(CASE WHEN HAS_ACTIVE_APPLICATION = "TRUE" THEN 1 END) APPLICANTS
  FROM dwellers_tenants
   GROUP BY AGE_GROUP
    ORDER BY SEARCHERS DESC;
    
    #5
    #5 What is the inspection-to-application conversion rate?
     SELECT INSPECTION_COUNT,
      COUNT(CASE WHEN HAS_ACTIVE_APPLICATION = "TRUE" THEN 1 END) APPLICATION_RATE
      FROM dwellers_tenants
       GROUP BY INSPECTION_COUNT
       ORDER BY APPLICATION_RATE DESC  ;
       
	#6
    #Which locations do tenants save most but rarely apply for?
    SELECT LOCATION,
    COUNT(CASE WHEN ACTION_TYPE = "SAVE" THEN 1 END)SAVES,
    COUNT(CASE WHEN HAS_ACTIVE_APPLICATION= "FALSE" THEN 1 END)NO_APPLICATION
    FROM DWELLERS_interactions DI
    JOIN dwellers_LISTINGS DL
    ON DI.LISTING_ID = DL.Listing_ID
    JOIN DWELLERS_TENANTS DT
    ON DI.TENANT_ID = DT.TENANT_ID
    GROUP BY LOCATION
    ORDER BY SAVES DESC;
    
    #7	
    #Which landlords post the most but receive the fewest applications?
    SELECT NAME,
    LISTING_COUNT AS POSTS, 
    COUNT(CASE WHEN Action_Type  = "APPLIED" THEN 1 END) NO_APPLICATION
    FROM DWELLERS_LANDLORDS DLA
    JOIN DWELLERS_LISTINGS DL
    ON DLA.LANDLORD_ID = DL.LANDLORD_ID
    JOIN dwellers_interactions DI
    ON DL.LISTING_ID = DI.LISTING_ID
    GROUP BY NAME, POSTS
    ORDER BY NO_APPLICATION desc;
    
    #8
    #Do verified landlords get more successful leases than non-verified?
    SELECT VERIFIED_STATUS,
    COUNT( DISTINCT CASE WHEN LEASE_SIGNED = "TRUE" THEN dli.LISTING_ID END)SUCCESSFUL_LEASE
    FROM dwellers_landlords DLA
    JOIN DWELLERS_LISTINGS DLI
    ON DLA.Landlord_ID = DLI.Landlord_ID
    JOIN DWELLERS_RENTAL_OUTCOMES DRO
    ON DLI.LISTING_ID = DRO.LISTING_ID
    GROUP BY VERIFIED_STATUS;
    
    #9	
    #How long (on average) does it take to rent out a property by location?
    SELECT LOCATION,CONCAT(AVG(DATEDIFF(OFFER_DATE,DATE_LISTED))," ","DAYS") AS DAYS_DIFFERENCE
    FROM DWELLERS_LISTINGS DLI
    JOIN DWELLERS_RENTAL_OUTCOMES DRO
    ON DLI.LISTING_ID = DRO.LISTING_ID
	WHERE LEASE_SIGNED = "TRUE"
    GROUP BY LOCATION;
      
    
   #10.	
    #Which listings have high saves/views but no inspections or applications?
    SELECT DL.LISTING_ID,
    COUNT(CASE WHEN ACTION_TYPE = "VIEW" OR ACTION_TYPE = "SAVE" THEN 1 END)VIEWS_SAVES,
    COUNT(CASE WHEN ACTION_TYPE="SCHEDULE_INSPECTION" OR "APPLIED" THEN 1 END)NO_APPLICATION
    FROM DWELLERS_LISTINGS DL
    JOIN DWELLERS_INTERACTIONS DI
    ON DL.LISTING_ID = DI.LISTING_ID
    JOIN DWELLERS_TENANTS DT
    ON DI.TENANT_ID = DT.TENANT_ID
    GROUP BY Listing_ID
    HAVING NO_APPLICATION = 0
    ORDER BY VIEWS_SAVES DESC;
    
    #11
    #Are there landlords with 10+ listings but no signed leases?
    SELECT NAME,COUNT(DLI.Listing_ID)NO_OF_LISTINGS,
    COUNT(CASE WHEN LEASE_SIGNED = TRUE THEN 1 END) LEASE_STATUS
    FROM DWELLERS_LANDLORDS DLA
    JOIN dwellers_listings DLI
    ON DLA.LANDLORD_ID = DLI.LANDLORD_ID
    JOIN DWELLERS_RENTAL_OUTCOMES DRO
    ON DLI.LISTING_ID = DRO.LISTING_ID
   GROUP BY NAME
   HAVING NO_OF_LISTINGS >=10 AND LEASE_STATUS = 0
   ORDER BY NO_OF_LISTINGS;
   
   #12
   #What is the overall lease success rate?
   SELECT 
   CONCAT(COUNT(CASE WHEN LEASE_SIGNED = "TRUE" THEN 1 END ) / COUNT(LEASE_SIGNED) * 100,"%") SUCCESS_RATE
   FROM DWELLERS_RENTAL_OUTCOMES;
   
   #13
   #What property types have the fastest turnover?
   
 #14  
 #Can we segment tenants based on high-engagement behaviors?
SELECT FULL_NAME,COUNT(HAS_ACTIVE_APPLICATION)
FROM DWELLERS_TENANTS DT
GROUP BY FULL_NAME ;
    
     

SELECT * FROM dwellers_interactions;
SELECT * FROM dwellers_landlords;
SELECT * FROM dwellers_listings;
SELECT * FROM dwellers_rental_outcomes;
SELECT * FROM dwellers_tenants;