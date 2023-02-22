
/*

Data cleaning

*/

Select *
From [Portfolio project]..Housing


--Standardize sale date

Select SalesDateConverted, CONVERT(Date,SaleDate)
From [Portfolio project]..Housing

Update Housing
Set SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE Housing
Add SalesDateConverted Date

Update Housing
Set SalesDateConverted = CONVERT(Date,SaleDate)


--Populate Property Address Data
Select *
From [Portfolio project]..Housing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio project]..Housing a
JOIN [Portfolio project]..Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio project]..Housing a
JOIN [Portfolio project]..Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [Portfolio project]..Housing
--where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress)) as Address 

From [Portfolio project]..Housing

ALTER TABLE Housing
Add PropertySplitAddress nvarchar (255)

Update Housing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1)



ALTER TABLE Housing
Add PropertySplitCity nvarchar (255)

Update Housing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress))


Select *
From [Portfolio project]..Housing



Select OwnerAddress
From [Portfolio project]..Housing


Select
Parsename(REPLACE(OwnerAddress, ',','.') ,3),
Parsename(REPLACE(OwnerAddress, ',','.') ,2),
Parsename(REPLACE(OwnerAddress, ',','.') ,1)

From [Portfolio project]..Housing


ALTER TABLE Housing
Add OwnerSplitAddress nvarchar (255)

Update Housing
Set OwnerSplitAddress = Parsename(REPLACE(OwnerAddress, ',','.') ,3)



ALTER TABLE Housing
Add OwnerSplitCity nvarchar (255)

Update Housing
Set OwnerSplitCity = Parsename(REPLACE(OwnerAddress, ',','.') ,2)


ALTER TABLE Housing
Add OwnerSplitState nvarchar (255)

Update Housing
Set OwnerSplitState = Parsename(REPLACE(OwnerAddress, ',','.') ,1)


Select *
From [Portfolio project]..Housing



--Change Y and N into YES & NO in Sold as vacant

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio project]..Housing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant

, Case when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
From [Portfolio project]..Housing


Update Housing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
From [Portfolio project]..Housing

--Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

From [Portfolio project]..Housing
--ORDER BY ParcelID
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--Removing unused columns

Select *
From [Portfolio project]..Housing

ALTER TABLE [Portfolio project]..Housing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE [Portfolio project]..Housing
DROP COLUMN SaleDate