--cleaning data in SQL Queries
*/
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format

SELECT SaleDateConverted, CAST(SaleDate as Date)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CAST(SaleDate as Date)

ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CAST(SaleDate as Date)

--Populate Property Address data 

SELECT*
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking out Address into Individual Columns(Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress
FROM  PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Change Y and N to Yes and No in 'Sold as Vacant' Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
      CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	       WHEN SoldAsVacant = 'N' THEN 'No' 
		   ELSE SoldAsVacant
		   END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	       WHEN SoldAsVacant = 'N' THEN 'No' 
		   ELSE SoldAsVacant
		   END

--Remove Duplicate
WITH RowNumCTE AS
(
SELECT
 *,
      ROW_NUMBER() OVER (PARTITION BY ParcelID,
	                                  PropertyAddress,
									  SalePrice, 
									  SaleDate, 
									  LegalReference
									  ORDER BY UniqueID) row_num
     
FROM  PortfolioProject.dbo.NashvilleHousing
--ORDER BY UniqueID
)
SELECT *  
FROM RowNumCTE
WHERE row_num >1

--DELETE Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate














