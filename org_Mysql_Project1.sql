
create database mysql_project1 ;
use mysql_project1;


-- CREATE TABLE tbl_book_loans (
--     book_loans_LoansID INT PRIMARY KEY AUTO_INCREMENT,
--     book_loans_BookID INT,
--     book_loans_BranchID INT,
--     book_loans_CardNo INT,
--     book_loans_DateOut DATE,
--     book_loans_DueDate DATE,
--     FOREIGN KEY (book_loans_BookID)
--         REFERENCES tbl_book (book_BookID)
--         ON DELETE CASCADE ON UPDATE CASCADE,
--     FOREIGN KEY (book_loans_BranchID)
--         REFERENCES tbl_library_branch (library_branch_BranchID)
--         ON DELETE CASCADE ON UPDATE CASCADE,
--     FOREIGN KEY (book_loans_CardNo)
--         REFERENCES tbl_borrower (borrower_CardNo)
--         ON DELETE CASCADE ON UPDATE CASCADE
-- );
desc tbl_book_loans;
alter table tbl_book_loans modify column book_loans_DueDate varchar(50);
truncate table tbl_book_loans;

create table tbl_book_authors(book_authors_AuthorID int primary key auto_increment,
book_authors_BookID int ,book_authors_AuthorName varchar(50));

alter table tbl_book_authors add constraint afk foreign key(book_authors_bookid) 
references tbl_book(book_bookid) ON DELETE CASCADE;

create table tbl_book(book_BookID int primary key,
book_title varchar(50) ,book_publisherName varchar(50));

-- elect * from tbl_book;
 
create table tbl_publisher(publisher_publisherName varchar(70) primary key,
publisher_publisherAddress varchar(80) ,publisher_publisherphone int);

alter table tbl_publisher modify column publisher_publisherphone varchar(50);
alter table tbl_publisher modify column publisher_publisheraddress varchar(100);
 
alter table tbl_book add constraint bfk foreign key(book_publisherName) 
references tbl_publisher(publisher_publisherName) ON DELETE CASCADE;

create table tbl_book_copies(book_copies_copiesID int primary key auto_increment,
book_copies_bookID int , foreign key(book_copies_bookID) references tbl_book(Book_bookID) ON DELETE CASCADE,
book_copies_branchId int,book_copies_No_Of_Copies int);

alter table tbl_book_copies add constraint bcfk foreign key(book_copies_branchid) 
references tbl_library_branch(library_branch_branchID) ON DELETE CASCADE; 

create table tbl_library_branch(library_branch_branchID int primary key auto_increment,
library_branch_branchName varchar(80) , library_branch_branchAddress varchar(80));

create table tbl_book_loans(book_loans_loansID int primary key auto_increment,
book_loans_bookID int , foreign key(book_loans_bookID) 
references tbl_book(Book_bookID) ON DELETE CASCADE,
book_loans_branchId int,foreign key(book_loans_branchid) 
references tbl_library_branch(library_branch_branchid) ON DELETE CASCADE,
book_loans_cardNo int,book_loans_dateout date, book_loans_duedate date);

create table tbl_borrower(borrower_cardno int primary key,borrower_borrowerName varchar(80),
borrower_borrowerAddress varchar(80),borrower_borrowerphone int);

alter table tbl_borrower modify column borrower_borrowerphone varchar(80);
alter table tbl_borrower modify column borrower_borrowerAddress varchar(100);

alter table tbl_book_loans add constraint blfk foreign key(book_loans_cardno) 
references tbl_borrower(borrower_cardno) ON DELETE CASCADE ;

desc tbl_publisher;
truncate table tbl_book_authors;

-- How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?


select distinct( book_copies_no_of_copies) from tbl_book_copies 
where book_copies_bookid in
(select book_copies_bookid from tbl_book where book_title = 'The Lost Tribe') and  
book_copies_branchid in
(select library_branch_branchid from tbl_library_branch where library_branch_branchname = 'Sharpstown');

-- How many copies of the book titled "The Lost Tribe" are owned by each library branch?


with cte_3 as
(select library_branch_branchname , book_copies_bookid,book_copies_no_of_copies from tbl_book_copies join tbl_library_branch 
on tbl_book_copies.book_copies_branchid  = tbl_library_branch.library_branch_branchid)
select book_copies_no_of_copies,library_branch_branchname from cte_3 
where book_copies_bookid in (select book_bookid from tbl_book 
where book_title = "The Lost Tribe");


-- Retrieve the names of all borrowers who do not have any books checked out.


select borrower_borrowername from tbl_borrower where borrower_cardno not in 
(select book_loans_cardno from tbl_book_loans); 

-- For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address. 


with cte_1 as
(select * from tbl_book inner join tbl_book_loans on tbl_book.book_bookid = tbl_book_loans.book_loans_bookid),
cte_2 as
(select * from tbl_borrower inner join cte_1 on   tbl_borrower.borrower_cardno = cte_1.book_loans_cardno)
select book_title,borrower_borrowername,borrower_borroweraddress from cte_2 
where book_loans_duedate = '2/3/18' and 
book_loans_branchid in (select library_branch_branchid from tbl_library_branch where library_branch_branchname = 'Sharpstown');

-- For each library branch, retrieve the branch name and the total number of books loaned out from that branch.


with cte_7 as
(select book_loans_branchid, count(*) as book_count from tbl_book_loans where book_loans_branchid in
(select library_branch_branchid from tbl_library_branch) group by book_loans_branchid)
select library_branch_branchname,book_count from cte_7 join tbl_library_branch on cte_7.book_loans_branchid =  tbl_library_branch.library_branch_branchid;

-- Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.

with cte_4 as 
(select book_loans_cardno,count(*) as total from tbl_book_loans group by book_loans_cardno having count(*) > 5)
select  borrower_borrowername,borrower_borroweraddress,total from cte_4 
join tbl_borrower on cte_4.book_loans_cardno = tbl_borrower.borrower_cardno;

 

-- For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".

SELECT book_title,book_copies_no_of_copies from tbl_book join 
tbl_book_authors on tbl_book_authors.book_authors_bookid = tbl_book.book_bookid
join tbl_book_copies on tbl_book.book_bookid = tbl_book_copies.book_copies_bookid 
join tbl_library_branch on library_branch_branchid = tbl_book_copies.book_copies_branchid
where book_authors_authorname = 'Stephen King' and library_branch_branchname = 'Central';








