-- Use Table Sheet 1 

-- Data Cleaning Nachville  02.04.2024

-------------------SaleDate----------------------------------
/*
    SaleDate, enthällt das Datum so wie die Zeit wir wollen aber nur das Datum 
    SELECT Convert(date,SaleDate) FROM SQL_Portfolio_Projekt..Nashville_DC;

    UPDATE SQL_Portfolio_Projekt..Nashville_DC
    SET SaleDate = Convert(date,SaleDate);
*/

SELECT * FROM SQL_Portfolio_Projekt..Nashville_DC;

ALTER TABLE Nashville_DC 
ADD SaleDateConverted DATE;

UPDATE SQL_Portfolio_Projekt..Nashville_DC
SET SaleDateConverted =  Convert(date,SaleDate);




----------------------- PropertyAddress---------------------------

 
/*
    PropertyAddress enthält NUll Values, die Frage ist wieso und kann man die umgehen
*/

SELECT 
    dc1.ParcelID, dc1.PropertyAddress,
    dc2.ParcelID, dc2.PropertyAddress,
    ISNULL(dc1.PropertyAddress,dc2.PropertyAddress)
FROM 
    SQL_Portfolio_Projekt..Nashville_DC dc1 JOIN SQL_Portfolio_Projekt..Nashville_DC dc2
    on dc1.ParcelID = dc2.ParcelID
    and dc1.[UniqueID ] <> dc2.[UniqueID ]
WHERE 
    dc1.PropertyAddress IS NULL ;

-- Hier erkennen wie das es einge PropertyAddress gibt die mehrfach vorkommen und nicht alle eine Addrese zugewissen bekommen haben 
-- Durch das Update haben wir die NULL Werte beseitigt und können uns jetzt dem aufteilen widmen 
UPDATE dc1
SET dc1.PropertyAddress = ISNULL(dc1.PropertyAddress, dc2.PropertyAddress)
    FROM 
    SQL_Portfolio_Projekt..Nashville_DC dc1 JOIN SQL_Portfolio_Projekt..Nashville_DC dc2
    on dc1.ParcelID = dc2.ParcelID
    and dc1.[UniqueID ] <> dc2.[UniqueID ]
WHERE 
    dc1.PropertyAddress IS NULL ;


SELECT 
    PropertyAddress
FROM
    SQL_Portfolio_Projekt..Nashville_DC
-- WHERE PropertyAddress is NULL  -- enthält keine NULL Values 

/*
    Für die Einteilung arbeite ich mit 
    SUBSTRING( Zeichenkette, Startposition, Länge ) 
    CHARINDEX( Suchzeichenfolge , Zeichenfolge [ , Startposition ] )

    Bedenke CHARINDEX gibt eine position zurück 
*/

SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Street,
    SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+2 ,LEN(PropertyAddress)-CHARINDEX(',',PropertyAddress ) - 1) as City
FROM
    SQL_Portfolio_Projekt..Nashville_DC;



-- Erstellen zwei neue Spalten in der Tabele Nashville damit wir unsere oberen Einteilunen diese zuordnen können 

ALTER TABLE NASHVILLE_DC
ADD street_property VARCHAR(255)

ALTER TABLE NASHVILLE_DC
ADD city_property VARCHAR(255)


UPDATE SQL_Portfolio_Projekt..Nashville_DC
SET street_property  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


UPDATE SQL_Portfolio_Projekt..Nashville_DC
SET city_property  = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+2 ,LEN(PropertyAddress)-CHARINDEX(',',PropertyAddress ) - 1)


----------------------------------Owner Adress -------------------------------------------------

/*
    Eine zweite Möglichkeit eine Spalte aufzuteilen ist die Parsename Funktion, hier bei ist es wichtig die ',' durch '.' zuersetzen 
    PARSENAME ( 'objektname' , index ) 
    REPLACE(Zeichenkette, Suchzeichenfolge, Ersetzungszeichenfolge)

*/

SELECT 
    Parsename(replace(OwnerAddress, ',' ,'.' ),1),
    Parsename(replace(OwnerAddress, ',' ,'.' ),2),
    Parsename(replace(OwnerAddress, ',' ,'.' ),3)
from 
    SQL_Portfolio_Projekt..Nashville_DC
where OwnerAddress is not NULL



ALTER TABLE Nashville_DC
ADD OwnerSplitStreet VARCHAR(255)

ALTER TABLE Nashville_DC
ADD OwnerSplitAddress VARCHAR(255)

ALTER TABLE Nashville_DC
ADD OwnerSplitStaat VARCHAR(255)

UPDATE SQL_Portfolio_Projekt..Nashville_DC
SET OwnerSplitStreet = Parsename(replace(OwnerAddress, ',' ,'.' ),3)

UPDATE SQL_Portfolio_Projekt..Nashville_DC
SET OwnerSplitAddress = Parsename(replace(OwnerAddress, ',' ,'.' ),2)


UPDATE SQL_Portfolio_Projekt..Nashville_DC
SET OwnerSplitStaat = Parsename(replace(OwnerAddress, ',' ,'.' ),1)


SELECT * FROM
SQL_Portfolio_Projekt..Nashville_DC
where OwnerAddress is not NULL

SELECT OwnerName from SQL_Portfolio_Projekt..Nashville_DC
where OwnerName IS not null


---------------------------------Ownername---------------------------------------------------



SELECT OwnerName from SQL_Portfolio_Projekt..Nashville_DC
where OwnerName IS not null

ALTER TABLE Nashville_DC
ADD OwnerSplitFirstname VARCHAR(255);

ALTER TABLE Nashville_DC
ADD OwnerSplitLastname VARCHAR(255);


SELECT 
    ownername,
    CASE 
        WHEN CHARINDEX(',', ownername) > 0 THEN LEFT(ownername, CHARINDEX(',', ownername) - 1)
        ELSE ownername -- Wenn kein Komma vorhanden ist, geben Sie den vollständigen Namen zurück
    END ,
    case
        WHEN CHARINDEX(',', OwnerName) > 0 then  RIGHT(OwnerName,len(OwnerName)- CHARINDEX(',', OwnerName))
        ELSE ownername -- Wenn kein Komma vorhanden ist, geben Sie den vollständigen Namen zurück
    end as nachname
FROM 
    SQL_Portfolio_Projekt..Nashville_DC
WHERE
    ownername IS NOT NULL;

UPDATE Nashville_DC
SET OwnerSplitFirstname = case
        WHEN CHARINDEX(',', OwnerName) > 0 then  RIGHT(OwnerName,len(OwnerName)- CHARINDEX(',', OwnerName))
        ELSE ownername -- Wenn kein Komma vorhanden ist, geben Sie den vollständigen Namen zurück
    end

UPDATE nashville_dc
SET OwnerSplitLastname = CASE 
        WHEN CHARINDEX(',', ownername) > 0 THEN LEFT(ownername, CHARINDEX(',', ownername) - 1)
        ELSE ownername -- Wenn kein Komma vorhanden ist, geben Sie den vollständigen Namen zurück
    END



----------------------------------------------SoldasVacant--------------------------------------------------------

-- wir haben Y, Yes, N, NO
-- Nutzen die Replace Abfrage um Y auf Yes umzuwadeln und N auf NO 

SELECT 
    distinct(SoldAsVacant)
FROM
    SQL_Portfolio_Projekt..Nashville_DC;


ALTER TABLE Nashville_DC
ADD SoldAsVacantUpdated VARCHAR(4)


SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' then REPLACE(SoldAsVacant,'Y','Yes')
        WHEN SoldAsVacant = 'N' then REPLACE(SoldAsVacant,'N','NO')
        ELSE SoldAsVacant
    END
FROM
    SQL_Portfolio_Projekt..Nashville_DC;


UPDATE Nashville_DC
SET SoldAsVacantUpdated = 
     CASE
        WHEN SoldAsVacant = 'Y' then REPLACE(SoldAsVacant,'Y','Yes')
        WHEN SoldAsVacant = 'N' then REPLACE(SoldAsVacant,'N','NO')
        ELSE SoldAsVacant
    END

SELECT 
    distinct(SoldAsVacantUpdated)
FROM
    SQL_Portfolio_Projekt..Nashville_DC;



------------------------------------------Duplicats------------------------------------------
-- Wenn wir selbst festlegen wollen welche Spalten nicht identisch sein dürfen nutzen wir CTEs

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num

From SQL_Portfolio_Projekt..Nashville_DC
--order by ParcelID
)


--gibt uns alle duplikate aus

Select *    -- Delete wenn wir sie löschen wollen 
From RowNumCTE
Where row_num > 1;


-- Wenn wir allgemein keine exakt identische Zeilen haben wollen nutzen wir distinct * 

SELECT 
    distinct * 
from    
    SQL_Portfolio_Projekt..Nashville_DC;


-- Eine andere allternative ist die UNION Methode 


------------------------------------------Drop columns that we dont use--------------------------------------------

ALTER TABLE Nashville_DC
DROP COLUMN PropertyAddress, SaleDate ,SoldasVacant, Ownername, OwnerAddress ----- alle unwichten spalten hinzufügen