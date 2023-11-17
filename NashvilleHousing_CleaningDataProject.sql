/*
Cleaning data in SQL Queries
*/


Select *
From PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------

--Standardize Data Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing


Update PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

Alter Table PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------

--Populate Property Address data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

--It is safe to assume that those with the same exact ParcelID should have the same Property address

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, IsNULL(A.PropertyAddress, B.PropertyAddress)
From PortfolioProject..NashvilleHousing as A
Join PortfolioProject..NashvilleHousing as B
	On A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null


Update A
SET PropertyAddress = IsNULL(A.PropertyAddress, B.PropertyAddress)
From PortfolioProject..NashvilleHousing as A
Join PortfolioProject..NashvilleHousing as B
	On A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null


Select *
From PortfolioProject..NashvilleHousing
Order by ParcelID

--------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address 

From PortfolioProject..NashvilleHousing


Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select *
From PortfolioProject..NashvilleHousing



Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) as Address
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) as City
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) as State
From PortfolioProject..NashvilleHousing




Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)


Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)


Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


Select *
From PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing


Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


--------------------------------------------------------------------------------------------------------

--Remove Duplicates 


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
					) row_num

From PortfolioProject..NashvilleHousing
--Order By ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


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
					) row_num

From PortfolioProject..NashvilleHousing
--Order By ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------

--Delete unused columns 

Select *
From PortfolioProject..NashvilleHousing



ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress



ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate