
USE House;
SELECT * FROM House.dbo.NashvileHousingProject;

-- Standardize Date format

SELECT Saledate, CONVERT(Date,SaleDate) FROM House.dbo.NashvileHousingProject;


ALTER TABLE NashvileHousingProject
ADD SaleDateConverted Date;

Update NashvileHousingProject
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaledateConverted, CONVERT(Date,SaleDate) FROM House.dbo.NashvileHousingProject;

-- Populate Property Address DATA

SELECT *
FROM House.dbo.NashvileHousingProject
WHERE PropertyAddress is null 

SELECT *
FROM House.dbo.NashvileHousingProject
ORDER BY ParcelID

-- Each ParcelID is going to have the same PropertyAddress 
-- i.e.  if ParcelID has a PropertyAddress in a row and that same ParcelID does not have in another row, we are going to populate it with already populated Address.
-- we are going to use UNIQUEID as an Identifier because it is a unique value

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM House.dbo.NashvileHousingProject a
JOIN House.dbo.NashvileHousingProject b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 


-- When you use joins in an update statement, you call out table name by their new alias. NashvilleHosingProject is 'a'

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM House.dbo.NashvileHousingProject a
JOIN House.dbo.NashvileHousingProject b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 



-- Breaking out Address into individual Columns(Address, City, State)

SELECT PropertyAddress
FROM House.dbo.NashvileHousingProject

--  We will use a substring and a CharacterIndex i.e. Charindex which will search for a specific value

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
FROM House.dbo.NashvileHousingProject

-- to remove the comma at the end of the Address we can add -1

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as Address
FROM House.dbo.NashvileHousingProject

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM House.dbo.NashvileHousingProject

-- We can't seperate a two values from onecolumn without creating two columns

ALTER TABLE NashvileHousingProject
ADD PropertySplitAddress Nvarchar(255);

Update NashvileHousingProject
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) 

ALTER TABLE NashvileHousingProject
ADD PropertySplitCity Nvarchar(255);

Update NashvileHousingProject
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) 

SELECT * FROM NashvileHousingProject


-- There's another way to do this. We use PARSENAME. However, PARSENAME only looks for PERIOD. So we can replacse the COMMAS with PERIOD

SELECT OwnerAddress FROM NashvileHousingProject

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM House.dbo.NashvileHousingProject


ALTER TABLE NashvileHousingProject
ADD OwnerSplitAddress Nvarchar(255);

Update NashvileHousingProject
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvileHousingProject
ADD OwnerSplitCity Nvarchar(255);

Update NashvileHousingProject
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvileHousingProject
ADD OwnerSplitState Nvarchar(255);

Update NashvileHousingProject
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * FROM NashvileHousingProject

--Change 'Y' and 'N' to 'Yes' and 'No' in 'SoldasVacant' field


SELECT DISTINCT(SoldasVacant),COUNT(SoldasVacant)
FROM House.dbo.NashvileHousingProject
GROUP BY SoldasVacant
ORDER BY 2

SELECT SoldasVacant
, CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
       WHEN SoldasVacant = 'N' THEN 'NO'
	   ELSE SoldasVacant 
	   END
FROM House.dbo.NashvileHousingProject


UPDATE NashvileHousingProject
SET SoldasVacant = CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
       WHEN SoldasVacant = 'N' THEN 'NO'
	   ELSE SoldasVacant 
	   END
FROM House.dbo.NashvileHousingProject


-- Remove Duplicates

-- To identify duplicate rows, you can use RANK, ORDER RANK, DENSE RANK, ROW NUMBER


SELECT *,
      ROW_NUMBER() OVER(
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   Saleprice,
				   SaleDate,
				   LegalReference
				   ORDER BY 
				      UniqueID) 
				   Row_Num

FROM House.dbo.NashvileHousingProject
ORDER BY ParcelID


WITH RownumCTE as(
SELECT *,
      ROW_NUMBER() OVER(
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   Saleprice,
				   SaleDate,
				   LegalReference
				   ORDER BY 
				      UniqueID) 
				   Row_Num

FROM House.dbo.NashvileHousingProject)
SELECT *
FROM RownumCTE
WHERE ROW_NUM > 1


-- DELETE UNSED COLUMNS

SELECT *
FROM House.dbo.NashvileHousingProject;

ALTER TABLE House.dbo.NashvileHousingProject
DROP COLUMN OwnerAddress,Taxdistrict, PropertyAddress 

ALTER TABLE House.dbo.NashvileHousingProject
DROP COLUMN SaleDate