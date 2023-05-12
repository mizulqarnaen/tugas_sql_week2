-- Tugas Assessment SQL Week #2
-- Name : Mohammad Iqbal
-- --------------------------

set autocommit = 0;

-- 3. Melakukan Transaction SQL 

-- Insert untuk 5 record & commited.

start transaction;

insert into offices values
	(8, 'Bandung', '+62 8211 1713 3380', 'Buah Batu', null, 'Jawa Barat', 'Indonesia', '40277', 'NA'),
	(9, 'Jakarta', '+62 8211 1713 3388', 'Tanah Abang', null, 'DKI Jakarta', 'Indonesia', '60444', 'NA'),
	(10, 'Surabaya', '+62 8211 1713 2280', 'Thamrin', null, 'Jawa Timur', 'Indonesia', '57731', 'NA'),
	(11, 'Medan', '+62 8211 0003 2280', 'Ahmad Yani', null, 'Sumatera Utara', 'Indonesia', '21330', 'NA'),
	(12, 'Singapore', '+60 8211 1713 3380', 'Bugis St', null, 'Bugis', 'Singapore', '07321', 'NA');

commit;

-- Insert/update/delete di 1 sesi dan read table di sesi yg berbeda. 

select * from offices o ;

-- hapus office singapore
delete from offices where officeCode = 12;

-- savepoint
savepoint hapuskantor;

-- cek data
select * from offices o ;

-- Rollback ke savepoint

rollback to savepoint hapuskantor;

-- tidak bisa menggunakan rollback to savepoint
-- namun jika menjalakan rollback saja bisa
rollback;

-- cek data setelah rollback
select * from offices o ;



set autocommit = 1;

-- 5. Eksekusi script sql subquery pada modul training:

-- SELECT 

select * from employees e where officeCode 
	in (select officeCode from offices o where country <> 'USA')
	order by officeCode;
	
-- INSERT 
insert into customers(customerNumber, customerName, contactLastName, contactFirstName, addressLine1, phone, city, state, postalCode, country)
	(select residentNumber, contactFirstName, contactLastName, contactFirstName, city, phone, city, state, postalCode, country 
	from resident where city = 'NYC');

-- UPDATE

-- cek produk paling banyak terjual
select productCode from orderdetails o group by productCode having count(productCode) order by count(productCode) desc limit 1;

-- cek data produk
select productCode, buyPrice from products p where productCode = (select productCode from orderdetails o group by productCode having count(productCode) order by count(productCode) desc limit 1);

-- update harga produk yang paling banyak terjual untuk dinaikan 5% harganya
update products set buyPrice = buyPrice + (buyPrice * 0.05)
	where productCode = (select productCode from orderdetails o group by productCode having count(productCode) order by count(productCode) desc limit 1);

-- DELETE

-- cek data
select * from orderdetails o 
	where productCode in (select productCode from products p where quantityInStock < 50) 
	and orderNumber in (select orderNumber from orders where year(orderDate) = '2003' and month(orderDate) = '02');

-- hapus order detail yang stok produknya kurang dari 50 dan ordernya di bulan february tahun 2003
delete from orderdetails
	where productCode in (select productCode from products p where quantityInStock < 50) 
	and orderNumber in (select orderNumber from orders where year(orderDate) = '2003' and month(orderDate) = '02');

-- Filter dari column dengan agregasi nilai paling besar

-- produk dengan jumlah stok terbanyak
select * from products p where quantityInStock = (select max(quantityInStock) from products);

-- Query dari Subquery sebagai source data

select customerFrance.customerName, o.orderNumber, o.orderDate, o.shippedDate, o.status 
	from (select customerNumber, customerName from customers where country = 'France') as customerFrance
	join orders o on customerFrance.customerNumber = o.customerNumber;

-- Combine query UNION 

select firstName from employees e
union
select contactFirstName from customers c 
order by firstName;

-- Combine query INTERSECT

-- karena tidak ada data yang mirip antar tabel untuk mencoba intersect
-- saya buat tabel baru

CREATE TABLE `resident` (
  `residentNumber` int(11) NOT NULL,
  `contactLastName` varchar(50) NOT NULL,
  `contactFirstName` varchar(50) NOT NULL,
  `phone` varchar(50) NOT NULL,
  `city` varchar(50) NOT NULL,
  `state` varchar(50) DEFAULT NULL,
  `postalCode` varchar(15) DEFAULT NULL,
  `country` varchar(50) NOT NULL,
  PRIMARY KEY (`residentNumber`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

insert into resident values
	(1, 'Iqbal', 'Mohammad', '82117133380', 'NYC', 'NY', '10022', 'USA'),
	(2, 'King', 'Jean', '7025551838', 'San Rafael', 'CA', '97562', 'USA'),
	(3, 'Frick', 'Steve', '9145554562', 'White Plains', 'NY', '24067', 'USA'),
	(4, 'Brad', 'Brian', '12312322', 'Los Angeles', 'CA', '91003', 'USA');

select * from resident r ;

select * from customers c ;

select contactFirstName, contactLastName from customers
intersect 
select contactFirstName, contactLastName from resident;

-- ternyata masih gagal mungkin karena versinya 5.7.39
	