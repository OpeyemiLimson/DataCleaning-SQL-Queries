--Data CLeaning Queries

select *
from PortfolioProject.dbo.NashvilleHousing

-- Standard the date format

select  SaleDateConverted, convert(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,SaleDate)

Alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted =  convert(date,SaleDate)


--Populate PropertyAddress data


select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out address to individual columns(Address, City, State)


select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , len(PropertyAddress)) as Address

from PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
add PropertySplitAddress nvarchar(225);

update NashvilleHousing
set PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter table NashvilleHousing
add PropertySplitCity nvarchar(225);

update NashvilleHousing
set  PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , len(PropertyAddress))

select *
from PortfolioProject..NashvilleHousing



select OwnerAddress
from PortfolioProject..NashvilleHousing

select
PARSENAME(replace(OwnerAddress, ',', '.') , 3)
,PARSENAME(replace(OwnerAddress, ',', '.') , 2)
,PARSENAME(replace(OwnerAddress, ',', '.') , 1)
from PortfolioProject..NashvilleHousing


Alter table NashvilleHousing
add OwnerSplitAddress nvarchar(225);

update NashvilleHousing
set OwnerSplitAddress =  PARSENAME(replace(OwnerAddress, ',', '.') , 3)

Alter table NashvilleHousing
add OwnerSplitCity nvarchar(225);

update NashvilleHousing
set  OwnerSplitCity =  PARSENAME(replace(OwnerAddress, ',', '.') , 2)

Alter table NashvilleHousing
add OwnerSplitState nvarchar(225);

update NashvilleHousing
set  OwnerSplitState =  PARSENAME(replace(OwnerAddress, ',', '.') , 1)

select *
from PortfolioProject..NashvilleHousing



-- Change Y and N to Yes and No "Sold As Vacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		else SoldAsVacant
		end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		else SoldAsVacant
		end
from PortfolioProject.dbo.NashvilleHousing


-- remove duplicates


WITH RowNumCTE AS(
select *,
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress

--delete unused columns

select *
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
 drop column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

 alter table NashvilleHousing
 drop column SaleDate