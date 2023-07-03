
select *
from Portfolio_Project.dbo.NashvilleHousing

-- Standardize Date to SaleDate

select SaleDateConverted, CONVERT(Date, SaleDate)
from Portfolio_Project.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address Data

Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing a
join Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing a
join Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null


	
-- Breaking out Address into Individual Columns (Address, City, State)

-- Breaking out PropertyAddress
select PropertyAddress
from Portfolio_Project.dbo.NashvilleHousing
order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) as Address

from Portfolio_Project.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))


select *
from Portfolio_Project.dbo.NashvilleHousing

-- Breaking out OwnerAddress

select OwnerAddress
From Portfolio_Project.dbo.NashvilleHousing

Select
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
From Portfolio_Project.dbo.NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in SoldAsVacant

Select Distinct(SoldAsVacant), count(SoldasVacant)
From Portfolio_Project.dbo.NashvilleHousing
Group By SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
From Portfolio_Project.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

-- Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
					UniqueID
					) row_num
from Portfolio_Project.dbo.NashvilleHousing
--order by ParcelID
)

select *
from RowNumCTE
where row_num > 1

-- Delete Unused Columns

Alter Table Portfolio_Project.dbo.NashvilleHousing
drop column SaleDate, OwnerAddress, PropertyAddress

select *
from Portfolio_Project.dbo.NashvilleHousing
