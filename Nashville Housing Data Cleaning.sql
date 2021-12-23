
--Standardize Date Format
select SaleDate, convert(Date, SaleDate)
from PortfolioProjectDatabase..Nashvillehousing

--Update Nashville Housing

Alter table Nashvillehousing
Add SaleDateConverted Date;

Update Nashvillehousing 
SET SaleDateConverted= convert(Date, SaleDate);

select SaleDateConverted from PortfolioProjectDatabase..Nashvillehousing

ALTER table Nashvillehousing DROP column SaleDate;

--Populate Property Address Data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjectDatabase.dbo.Nashvillehousing a
JOIN PortfolioProjectDatabase.dbo.Nashvillehousing b
	on a.ParcelID= b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

Update a
set PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjectDatabase.dbo.Nashvillehousing a
JOIN PortfolioProjectDatabase.dbo.Nashvillehousing b
	on a.ParcelID= b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

select * from PortfolioProjectDatabase.dbo.Nashvillehousing-- where PropertyAddress is null

--Breaking out Property Address into Individual columns(Address, City)
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City 
from PortfolioProjectDatabase.dbo.Nashvillehousing;

--Adding Split Info into Table
ALTER TABLE Nashvillehousing
ADD PropertySplitAddress nvarchar(255);

Update Nashvillehousing
SET PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashvillehousing
ADD PropertySplitCity nvarchar(255);

Update Nashvillehousing
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

select * from Nashvillehousing
ALTER table Nashvillehousing DROP column PropertyAddress;


--Breaking out Owner Address into Individual columns(Address, City, State)
select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
from PortfolioProjectDatabase.dbo.Nashvillehousing;


ALTER TABLE Nashvillehousing
ADD OwnerSplitAddress nvarchar(255);

Update Nashvillehousing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE Nashvillehousing
ADD OwnerSplitCity nvarchar(255);

Update Nashvillehousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE Nashvillehousing
ADD OwnerSplitState nvarchar(255);

Update Nashvillehousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

select * from PortfolioProjectDatabase.dbo.Nashvillehousing;
alter table nashvillehousing drop column owneraddress

select distinct soldasvacant from nashvillehousing


select soldasvacant, 
CASE WHEN soldasvacant= 'Y' THEN 'Yes'
	 WHEN soldasvacant= 'N' THEN 'No'
	 ELSE soldasvacant
	 END
from nashvillehousing

UPDATE nashvillehousing
SET soldasvacant= CASE WHEN soldasvacant= 'Y' THEN 'Yes'
	 WHEN soldasvacant= 'N' THEN 'No'
	 ELSE soldasvacant
	 END
from nashvillehousing


--Drop Unused Columns

ALTER TABLE nashvillehousing
DROP COLUMN TaxDistrict

select * from nashvillehousing