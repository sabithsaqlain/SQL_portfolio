/*

Cleaning Data in SQL Queries

*/

-- Standardize Date Format

select *
from nashvillehousing;

Alter table nashvillehousing
modify column SaleDate date;



---------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IfNULL(a.PropertyAddress,b.PropertyAddress) as PropertyAddress1
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID
Where a.PropertyAddress is null;

UPDATE NashvilleHousing a
JOIN NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;



---------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select substring(propertyaddress,1,locate(',',PropertyAddress)-1) as propertysplitAddress, substring(propertyaddress,locate(',',PropertyAddress)+1) as propertysplitCity
from nashvillehousing;

alter table nashvillehousing
Add propertysplitAddress text , add propertysplitCity text;

update nashvillehousing
set propertysplitAddress = substring(propertyaddress,1,locate(',',PropertyAddress)-1);

update nashvillehousing
set propertysplitCity = substring(propertyaddress,locate(',',PropertyAddress)+1);

-- Breaking out owner address

SELECT SUBSTRING_INDEX(ownerAddress, ',', 1) AS OwnersplitAddress,
SUBSTRING_INDEX(SUBSTRING_INDEX(ownerAddress,',', 2), ',',-1) AS OwnersplitCity,
SUBSTRING_INDEX(ownerAddress, ',', -1) as OwnersplitState FROM nashvillehousing;


alter table nashvillehousing
add OwnersplitAddress text,
add OwnersplitCity text,
add OwnersplitState text;

update nashvillehousing
set OwnersplitAddress = SUBSTRING_INDEX(ownerAddress, ',', 1);
update nashvillehousing 
set OwnersplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(ownerAddress,',', 2), ',',-1);
update nashvillehousing 
set OwnersplitState = SUBSTRING_INDEX(ownerAddress, ',', -1);

select *
from nashvillehousing;



---------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(soldasvacant),count(soldasvacant)
from nashvillehousing
group by soldasvacant
order by 2;

select SoldAsVacant,
Case when soldasvacant = 'Y' Then 'Yes' 
when soldasvacant = 'N' Then 'No'
else soldasvacant
end
from nashvillehousing;

update nashvillehousing
set soldasvacant = Case when soldasvacant = 'Y' Then 'Yes' 
when soldasvacant = 'N' Then 'No'
else soldasvacant
end;



---------------------------------------------------------------------------------------------------------


-- Remove Duplicates

-- In MYSQL CTE does not delete a table so using temp table to remove duplicates

drop table if exists temp_table;
create temporary table temp_table like nashvillehousing;
select *
from temp_table;

alter table temp_table
Add row_num int;

insert into temp_table
select *,
row_number() over(
partition by ParcelID, SalePrice, SaleDate, LegalReference order by UniqueID) row_num
from nashvillehousing;

DELETE
from temp_table
where row_num>1;


-- CTE
with rownumCTE as (
select *,
row_number() over(
partition by ParcelID, SalePrice, SaleDate, LegalReference order by UniqueID) row_num
from nashvillehousing)

select * 
from rownumCTE
where row_num>1
order by PropertyAddress;


-- Creating a subquery in FROM statement instead of using CTE
select * 
from (
select *,row_number() over(partition by ParcelID) as rnumber
from nashvillehousing) x
where x.rnumber > 1;



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from nashvillehousing;

alter table nashvillehousing
drop  OwnerAddress,
drop  taxdistrict,
drop  propertyaddress;


