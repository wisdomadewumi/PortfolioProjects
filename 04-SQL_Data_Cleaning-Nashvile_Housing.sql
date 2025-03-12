/*

Data Cleaning Project

*/


USE PortfolioProject
;

SELECT
	*
FROM NashvilleHousing -- Original Table
;


-- Before we clean the data, it would be necessary to clone the actual table and do all of the data cleaning on there to avoid a lasting damage to any column or record in the original table.
-- This can be done via a CTAS

SELECT
	*
INTO NashvilleHousing2
FROM NashvilleHousing
;

-- Checking newly cloned table
SELECT
	*
FROM NashvilleHousing2
;


---------------------------------------------------------------

-- Remove Duplicates

-- ROW_NUMBER can be used to find duplicates after partitioning by columns whose record shouldn't appear more than once. As a result, UniqueID is not part of this process.
-- Using a subquery (Hint: a CTE could also be used here)

SELECT *
FROM (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY
				ParcelID,
				SaleDate,
				PropertyAddress,
				LegalReference,
				SalePrice
			ORDER BY SaleDate
		) AS Row_Num
	FROM NashvilleHousing2
) t
WHERE Row_Num > 1 -- If row number appears more than once, then that's a duplicate record regardless of a distinct UniqueID
;

-- There are 104 duplicate records. Now, delete them from table
-- Here, I use a CTE

WITH CTE_Duplicates AS
(
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY
				ParcelID,
				SaleDate,
				PropertyAddress,
				LegalReference,
				SalePrice
			ORDER BY SaleDate
		) AS Row_Num
	FROM NashvilleHousing2
)

DELETE
FROM CTE_Duplicates
WHERE Row_Num > 1
;


---------------------------------------------------------------

-- Standardize Date Format

SELECT
	SaleDate -- Date format is DATETIME, we want it in DATE data type
FROM NashvilleHousing2
;

	-- Modifying SaleDate Column from DATETIME to DATE
	ALTER TABLE NashvilleHousing2
	ALTER COLUMN SaleDate DATE
	;


---------------------------------------------------------------

-- Populate Property Address Data

SELECT
	ParcelID,
	PropertyAddress
FROM NashvilleHousing2
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID
;
-- Browsing through both columns side by side, there is a trend of ParcelIDs being associated with specific property addresses
-- So we can populate NULL cells within PropertyAddress using ParcelID as a reference.


	-- Let's join the table on itself and use COALESCE to fill in NULL values

	SELECT
		t1.ParcelID,
		t1.PropertyAddress,
		t2.ParcelID,
		t2.PropertyAddress,
		COALESCE(t1.PropertyAddress,t2.PropertyAddress)
	FROM NashvilleHousing2 AS t1
	JOIN NashvilleHousing2 AS t2
		ON t1.ParcelID = t2.ParcelID
		AND t1.UniqueID != t2.UniqueID
	WHERE t1.PropertyAddress IS NULL
	;


	-- Now we update the NULL values with its suitable data
	UPDATE t1
	SET PropertyAddress = COALESCE(t1.PropertyAddress,t2.PropertyAddress)
	FROM NashvilleHousing2 AS t1
	JOIN NashvilleHousing2 AS t2
		ON t1.ParcelID = t2.ParcelID
		AND t1.UniqueID != t2.UniqueID
	WHERE t1.PropertyAddress IS NULL
	;


---------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT
	PropertyAddress,
	OwnerAddress
FROM NashvilleHousing2
;


-- First split the PropertyAddress into Address and City
SELECT
	PropertyAddress,
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) AS City
FROM NashvilleHousing2
;


	-- Then insert a new column for #Address from split PropertyAddress
	ALTER TABLE NashvilleHousing2
	ADD PropertySplitAddress NVARCHAR(255)

	UPDATE NashvilleHousing2
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


	-- And insert a new column for #City from split PropertyAddress
	ALTER TABLE NashvilleHousing2
	ADD PropertySplitCity NVARCHAR(255)

	UPDATE NashvilleHousing2
	SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))
;



-- Next, split the OwnerAddress into Address, City and State
SELECT
	OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
	PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 2) AS City,
	PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 1) AS State
FROM NashvilleHousing2
;


	-- Then insert a new column for #Address from split OwnerAddress
	ALTER TABLE NashvilleHousing2
	ADD OwnerSplitAddress NVARCHAR(255)

	UPDATE NashvilleHousing2
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


	-- And insert a new column for #City from split OwnerAddress
	ALTER TABLE NashvilleHousing2
	ADD OwnerSplitCity NVARCHAR(255)

	UPDATE NashvilleHousing2
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 2)


	-- And insert a new column for #State from split OwnerAddress
	ALTER TABLE NashvilleHousing2
	ADD OwnerSplitState NVARCHAR(255)

	UPDATE NashvilleHousing2
	SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 1)


-- Checking newly added columns
SELECT
	*
FROM NashvilleHousing2
;


---------------------------------------------------------------

-- Change 1 and 0 to Yes and No in "Sold as Vacant" field

SELECT
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 0 THEN 'No'
		WHEN SoldAsVacant = 1 THEN 'Yes'
		ELSE SoldAsVacant
	END AS SoldAsVacantText
FROM NashvilleHousing2
;


	-- Modify SoldAsVacant from BIT data type to string
	ALTER TABLE NashvilleHousing2
	ALTER COLUMN SoldAsVacant VARCHAR(10)

	-- Now insert more legible values from CASE WHEN statement above
	UPDATE NashvilleHousing2
	SET SoldAsVacant =	
		CASE
			WHEN SoldAsVacant = 0 THEN 'No'
			WHEN SoldAsVacant = 1 THEN 'Yes'
			ELSE SoldAsVacant
		END
	;



---------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM NashvilleHousing2


-- Deleting 3 columns that are not required anymore
ALTER TABLE NashvilleHousing2
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict
;


----------------------------------------------------------------

-- Data cleaning is done!

/*
Shout out to: Alex The Analyst
*/