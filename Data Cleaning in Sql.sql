/*
Cleaning Data in SQL Queries
*/
select * from [NashvilleHousing  ]
--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format
select SaleDateConverted,CONVERT(Date,SaleDate)
from [PortfolioProject ].dbo.[NashvilleHousing  ]

update [NashvilleHousing  ]
set SaleDate = CONVERT(Date,SaleDate)

alter table NashvilleHousing  
add SaleDateConverted Date

update [NashvilleHousing  ]
set SaleDate = CONVERT(Date,SaleDate)
 --------------------------------------------------------------------------------------------------------------------------

 -- Populate Property Address data
Select *
from [PortfolioProject ].dbo.[NashvilleHousing  ]
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from [PortfolioProject ].dbo.[NashvilleHousing  ] as a
join [PortfolioProject ].dbo.[NashvilleHousing  ] as b 
	on a.ParcelID =b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [PortfolioProject ].dbo.[NashvilleHousing  ] a
join [PortfolioProject ].dbo.[NashvilleHousing  ] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from [PortfolioProject ].dbo.[NashvilleHousing  ]
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 ,LEN(PropertyAddress)) as Address

from [PortfolioProject ].dbo.[NashvilleHousing  ]

alter table NashvilleHousing  
add PropertySplitAddress nvarchar(255);

update [NashvilleHousing  ]
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing  
add PropertySplitCity nvarchar(255);

update [NashvilleHousing  ]
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 ,LEN(PropertyAddress)) 

select * 
from [PortfolioProject ].dbo.[NashvilleHousing  ]




select OwnerAddress
from [PortfolioProject ].dbo.[NashvilleHousing  ]


select
PARSENAME(replace(OwnerAddress,',','-'),3),
PARSENAME(replace(OwnerAddress,',','-'),2),
PARSENAME(replace(OwnerAddress,',','-'),1)
from [PortfolioProject ].dbo.[NashvilleHousing  ]

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
from [PortfolioProject ].dbo.[NashvilleHousing  ]
group by SoldAsVacant
order by SoldAsVacant


select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 end
from [PortfolioProject ].dbo.[NashvilleHousing  ]

update [NashvilleHousing  ]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

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

from [PortfolioProject ].dbo.[NashvilleHousing  ]
--order by ParcelID
)
select * 
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress
Select *
from [PortfolioProject ].dbo.[NashvilleHousing  ]

---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select *
from [PortfolioProject ].dbo.[NashvilleHousing  ]

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
