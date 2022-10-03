USE Bank
GO

------------------------------------------------ BÀI TẬP TỔNG HỢP -----------------------------------------------------------------------


-- CÂU 1: Có bao nhiêu KH có ở Quảng Nam thuộc chi nhánh ngân hàng Vietcombank Đà Nẵng
--Bảng: customer, branch
--Cột: count số lượng kh
--ĐK: ở QN, chi nhánh ĐN
SELECT COUNT(*) SoLuongKH
FROM dbo.customer,dbo.Branch
WHERE Cust_ad LIKE N'%Quảng Nam' AND BR_ad LIKE N'%Đà Nẵng'

SELECT COUNT(*) SoLuongKH
FROM dbo.customer JOIN dbo.Branch ON dbo.customer.Br_id=dbo.Branch.BR_id
WHERE Cust_ad LIKE N'%Quảng Nam' AND BR_name LIKE N'%Vietcombank Đà Nẵng%'



-- CÂU 2: Hiển thị danh sách KH thuộc chi nhánh Vũng Tàu và số dư trong tài khoản của họ.
--Bảng: customer, branch, account
--Cột: cust_name, br_name, ac_balance
--ĐK: br_VungTau
SELECT Cust_name AS TenKH, BR_name AS ChiNhanh, ac_balance AS SoDuTK
FROM dbo.customer, dbo.account, dbo.Branch
WHERE dbo.customer.Cust_id=dbo.account.cust_id AND dbo.customer.Br_id=dbo.Branch.BR_id
AND BR_name LIKE N'%Vũng Tàu'

SELECT Cust_name AS TenKH, BR_name AS ChiNhanh, ac_balance AS SoDuTK
FROM dbo.customer JOIN dbo.account ON account.cust_id = customer.Cust_id
                  JOIN dbo.Branch ON Branch.BR_id = customer.Br_id
WHERE BR_name LIKE N'%Vũng Tàu'



-- Câu 3: Trong quý I năm 2012, có bao nhiêu khách hàng thực hiện giao dịch rút tiền tại ngân hàng Vietcombank --
-- bảng: transactions, bank, customer
-- cột: đếm slg KH
-- điều kiện: quý 1 năm 2022 (tháng 1-3), giao dịch rút tiền, ngân hàng vietcombank
SELECT COUNT(DISTINCT dbo.customer.Cust_id) AS SoLuongKH
FROM dbo.customer, dbo.Branch, dbo.Bank, dbo.transactions, dbo.account
WHERE dbo.customer.Br_id=dbo.Branch.BR_id AND dbo.Branch.B_id=dbo.Bank.b_id 
AND dbo.customer.Cust_id = dbo.account.cust_id AND dbo.account.Ac_no = dbo.transactions.ac_no
AND   dbo.transactions.t_type=0 AND YEAR(dbo.transactions.t_date)=2012
                                AND MONTH(dbo.transactions.t_date) BETWEEN 1 AND 3

SELECT COUNT(DISTINCT dbo.customer.Cust_id) AS SoLuongKH
FROM dbo.account JOIN dbo.transactions ON transactions.ac_no = account.Ac_no
                 JOIN dbo.customer ON customer.Cust_id = account.cust_id
				 JOIN dbo.Branch ON Branch.BR_id = customer.Br_id
				 JOIN dbo.Bank ON Bank.b_id = Branch.B_id
WHERE dbo.transactions.t_type=0 AND YEAR(dbo.transactions.t_date)=2012
                                AND MONTH(dbo.transactions.t_date) BETWEEN 1 AND 3



-- CÂU 4: Thống kê số lượng giao dịch, tổng tiền giao dịch trong từng tháng của năm 2014
-- Cột: tháng, slg giao dịch, tổng tiền giao dịch
-- Bảng: transactions
-- Đk: (từng tháng = group by), năm 2014
SELECT MONTH(t_date) AS Thang, COUNT(*) SLGGiaoDich, SUM(t_amount) AS TongTienGiaoDich
FROM dbo.transactions
WHERE YEAR(t_date) = 2014
GROUP BY MONTH(t_date)



-- CÂU 5: Thống kê tổng tiền KH gửi của mỗi chi nhánh, sắp xếp theo thứ tự giảm dần của tổng tiền
--Bảng: customer, branch, account, transactions
--Cột: sum(t_amount), br_name
--ĐK: t_type=1, DESC (mđ: order by), có gr by
SELECT BR_name AS N'Chi nhánh', SUM(t_amount) AS N'Tổng tiền gd'
FROM dbo.customer JOIN dbo.Branch ON Branch.BR_id = customer.Br_id
                  JOIN dbo.account ON account.cust_id = customer.Cust_id
				  JOIN dbo.transactions ON transactions.ac_no = account.Ac_no
WHERE t_type=1
GROUP BY BR_name
ORDER BY SUM(t_amount) DESC



-- CÂU 6: Chi nhánh Sài Gòn có bao nhiêu KH không thực hiện bất kỳ giao dịch nào trong vòng 3 năm trở lại đây. 
--        Nếu có thể, hãy hiển thị tên và số điện thoại của các khách đó để phòng marketing xử lý.
-- Cột:  count (khách hàng không thực hiện giao dịch), cust_name, cust_phone
-- Bảng: branch, customer, transactions, account
-- Đk:   1,chi nhánh SG, 
--       2,trong bảng transactions không có STK của họ, 
--       3,thời gian giao dịch >= getday() - 3 năm
-- Cô làm: lấy những ac_no (stk) mà thực hiện gd trong 3 năm trở lại đây, xong join mấy bảng còn lại rồi NOT IN ở đk WHERE
SELECT DISTINCT Cust_name, Cust_phone
FROM dbo.Branch JOIN dbo.customer ON customer.Br_id = Branch.BR_id
                JOIN dbo.account ON account.cust_id = customer.Cust_id
WHERE BR_name = N'Vietcombank Sài Gòn'
AND Ac_no NOT IN (SELECT Ac_no
                  FROM dbo.transactions
				  WHERE t_date >= DATEADD(YEAR, -3, GETDATE()))



-- CÂU 7: Thống kê thông tin giao dịch theo mùa, nội dung thống kê gồm: số lượng giao dịch, 
--        lượng tiền giao dịch trung bình, tổng tiền giao dịch, lượng tiền giao dịch nhiều nhất, lượng tiền giao dịch ít nhất.
--Bảng: transactions
--Cột: Mùa(qq=quater=quý), Count(số lượng gd, thể hiện qua t_id), AVG (lượng tiền gd tbinh, thể hiện qua t_amount),
--     Sum(tổng tiền gd), Max(lượng tiền gd nhiều nhất), Min(lượng tiền gd ít nhất)
--ĐK: group by 
SELECT DATEPART(qq,t_date) AS N'Mùa',
       COUNT(t_id) AS N'Số lượng GD',
	   AVG(t_amount) AS N'Lượng tiền gd trung bình',
	   SUM(t_amount) AS N'Tổng tiền gd',
	   MAX(t_amount) AS N'Lượng tiền gd nhiều nhất',
	   MIN(t_amount) AS N'Lượng tiền gd ít nhất'
FROM dbo.transactions
GROUP BY DATEPART(qq,t_date)



-- CÂU 8: Tìm số tiền giao dịch nhiều nhất trong năm 2016 của chi nhánh Huế. 
--        Nếu có thể, hãy đưa ra tên của KH thực hiện giao dịch đó.
--Bảng: transactions, branch, customer, account
--Cột: cust_name, max(t_amount)
--ĐK: năm 2016, chi nhánh Huế
SELECT Cust_name, MAX(t_amount) AS N'Số tiền gd nhiều nhất'
FROM dbo.customer JOIN dbo.Branch ON Branch.BR_id = customer.Br_id
                  JOIN dbo.account ON account.cust_id = customer.Cust_id
				  JOIN dbo.transactions ON transactions.ac_no = account.Ac_no
WHERE BR_name LIKE N'%Huế' AND YEAR(t_date)=2016
GROUP BY Cust_name


-- CÂU 9: Tìm KH có lượng tiền gửi nhiều nhất vào NGÂN HÀNG trong năm 2017 (nhằm mục đích tri ân KH)
--Bảng: customer, transactions, account
--Cột: cust_name, max(t_amount) (lượng tiền gửi nhiều nhất)
--ĐK: t_type=1, năm 2017
SELECT Cust_name, MAX(t_amount) AS N'Số tiền gửi nhiều nhất năm 2017'
FROM dbo.customer JOIN dbo.account ON account.cust_id = customer.Cust_id
                  JOIN dbo.transactions ON transactions.ac_no = account.Ac_no
WHERE YEAR(t_date)=2017 AND t_type=1
                        AND t_amount >= ALL (SELECT t_amount
						                     FROM dbo.customer JOIN dbo.account ON account.cust_id = customer.Cust_id
											                   JOIN dbo.transactions ON transactions.ac_no = account.Ac_no
											 WHERE YEAR(t_date)=2017 AND t_type=1)
GROUP BY Cust_name



-- CÂU 10: Tìm những KH có cùng chi nhánh với ông Phan Nguyên Anh
--Bảng: customer, branch
--Cột: cust_name,
--ĐK: cùng chi nhánh
--
SELECT DISTINCT Cust_name, customer.Br_id
FROM dbo.customer, dbo.Branch
WHERE customer.Br_id = (SELECT Br_id
                        FROM dbo.customer
						WHERE Cust_name = N'Phan Nguyên Anh')
AND Cust_name <> N'Phan Nguyên Anh' -- loại ông PNA ra --



-- CÂU 11: Liệt kê những GD thực hiện cùng giờ với giao dịch của ông Lê Nguyễn Hoàng Văn ngày 2016-12-02
--Bảng: transactions, customer, account
--Cột: cust_nảm, giờ, ngày
--ĐK: cùng giờ cùng ngày với ông Văn
SELECT DISTINCT Cust_name, t_date, t_time
FROM dbo.customer JOIN dbo.account ON account.cust_id = customer.Cust_id
                  JOIN dbo.transactions ON transactions.ac_no = account.Ac_no
WHERE t_date = '2016-12-02' 
AND DATEPART(hh, t_time) = ( SELECT DATEPART(hh, t_time)
							 FROM customer JOIN  account	 on customer.Cust_id=account.cust_id
										   JOIN transactions on  account.Ac_no=transactions.ac_no 
							 WHERE Cust_name = N'Lê Nguyễn Hoàng Văn' and t_date = '2016-12-02' )
AND Cust_name <> N'Lê Nguyễn Hoàng Văn' -- loại ông Lê Nguyễn Hoàng Văn ra --



-- CÂU 12: Hiển thị danh sách KH ở cùng thành phố với Trần Văn Thiện Thanh
--Bảng: customer
--Cột: cust_name, cust_ad
--ĐK: cùng thành phố với ông Thanh
SELECT Cust_name, Cust_ad
FROM dbo.customer
WHERE ltrim(right(Cust_ad,charindex(',',reverse(replace(cust_ad,'-',' ,')))-1)) LIKE
	       ( SELECT ltrim(right(Cust_ad,charindex(',',reverse(replace(cust_ad,'-',' ,')))-1))
		     FROM customer
			 WHERE Cust_name = N'Trần Văn Thiện Thanh')
AND Cust_name <> N'Trần Văn Thiện Thanh' -- Loại ông TVTT ra --



-- CÂU 13: Tìm những giao dịch diễn ra cùng ngày với giao dịch có mã số 0000000217
--Cột: t_id, t_date
--Bảng: transactions
--ĐK: CÙNG ngày
select t_id, t_date
from dbo.transactions
where DATEPART(dd, t_date) = ( SELECT DATEPART(dd, t_date)
							   FROM dbo.transactions
							   WHERE t_id =0000000217 )
AND t_id <> 0000000217 -- loại số gd ni ra



-- CÂU 14: Tìm những giao dịch cùng loại với giao dịch có mã số 0000000387
--Cột: t_id, t_type
--Bảng: transactions
--ĐK: cùng loại
SELECT t_id, t_type
FROM dbo.transactions
WHERE t_type = ( SELECT t_type
	             FROM dbo.transactions
				 WHERE t_id = 0000000387 )
AND t_id <> 0000000387



-- ???? CÂU 15: Những chi nhánh nào thực hiện nhiều GD gửi tiền trong tháng 12/2015 hơn chi nhánh Đà Nẵng
--Bảng: branch, transactions, customer, account
--Cột: br_name
--ĐK: t_type = 1, tháng 12/2015, nhiều hơn br_name like đà nẵng
select distinct BR_name
from Branch join customer on customer.Br_id = Branch.BR_id
			join  account on customer.Cust_id=account.cust_id
			join transactions on  account.Ac_no=transactions.ac_no 
where MONTH(t_date) = 12 and YEAR(t_date) = 2015 and t_type=1
group by BR_name
having COUNT(t_id) > (select COUNT(t_id)
						from Branch join customer on customer.Br_id = Branch.BR_id
									join  account on customer.Cust_id=account.cust_id
									join transactions on  account.Ac_no=transactions.ac_no 
									where MONTH(t_date) = 12 and YEAR(t_date) = 2015 and t_type=1  and BR_name LIKE N'%Đà Nẵng')



-- CÂU 16: Hãy liệt kê những tài khoảng trong vòng 6 tháng trở lại đây không phát sinh giao dịch
--Bảng: account, transactions
--Cột: ac_no, ac_type
--ĐK: kh có gd trong 6 tháng gần nhất
SELECT account.Ac_no
FROM dbo.account  JOIN dbo.transactions ON transactions.ac_no = account.Ac_no
WHERE t_date >= DATEADD(MONTH, -6, GETDATE()) AND 
	  account.Ac_no NOT IN ( SELECT account.Ac_no
							 FROM dbo.account JOIN dbo.transactions ON transactions.ac_no = account.Ac_no
							 WHERE t_date >= DATEADD(MONTH, -6, GETDATE()))


			
-- CÂU 17: Ông Phạm Duy Khánh thuộc chi nhánh nào? Từ 01/2017 đến nay ông Khánh đã thực hiện bnhieu GD gửi tiền 
--         vào ngân hàng với tổng số tiền là bao nhiêu.
--Cột: tên chi nhánh, số lượng gd gửi tiền (lắp truy vấn con vào), tổng tiền giao dịch (lắp tvan con)
--Bảng: branch, customer, transactions, account
--ĐK: từ 01/2017, t_type = 1, cust_name = PDK
SELECT BR_name AS N'Chi nhánh', COUNT(t_amount) AS N'Số lượng giao dịch', SUM(t_amount) AS N'Tổng tiền giao dịch', t_date AS N'Ngày'
FROM  dbo.Branch JOIN dbo.customer ON customer.Br_id = Branch.BR_id
				 JOIN dbo.account ON account.cust_id = customer.Cust_id
				 JOIN transactions ON transactions.ac_no = account.Ac_no
WHERE Cust_name = N'Phạm Duy Khánh' AND t_type =1 
								    AND year(t_date) > 2015
GROUP by Branch.BR_name, t_date



-- CÂU 18: Thống kê GD theo từng năm, nội dung thống kê gồm: số lượng giao dịch, lượng tiền giao dịch trung bình
--Bảng: transactions
--Cột: Year(t_date), COUNT(t_id), AVG
--ĐK: không
SELECT YEAR(t_date) AS N'Năm', 
       COUNT(t_id) AS  N'Số lượng giao dịch',
	   AVG(t_amount) AS N'Lượng tiền giao dịch trung bình'
FROM dbo.transactions
GROUP BY YEAR(t_date)


--????? CÂU 19: Thống kê SLG GD theo ngày và đêm trong năm 2017 ở chi nhánh Hà Nội, Sài Gòn
--Bảng: transactions, branch, customer, account
--Cột: Count(t_id)
--ĐK: ngày và đêm, 2017, HÀ NỘI, SG
SELECT BR_name, count(t_id) SOLUONG
FROM  Branch JOIN customer on customer.Br_id = Branch.BR_id
			 JOIN  account on customer.Cust_id=account.cust_id
			 JOIN transactions on  account.Ac_no=transactions.ac_no 
WHERE year(t_date) = 2017 AND BR_name LIKE N'%Hà Nội%' OR BR_name LIKE N'%Sài Gòn%' 
GROUP by BR_name



-- CÂU 20: Hiển thị danh sách khách hàng chưa thực hiện giao dịch nào trong năm 2017?
--Bảng: customer, transactions, account
--Cột: cust_name, cust_id
--ĐK: 2017, chưa gd
SELECT DISTINCT cust_id AS 'ID Khách hàng', Cust_name AS HovaTen
FROM dbo.customer
WHERE cust_id NOT IN   (SELECT DISTINCT dbo.customer.Cust_id
                        FROM dbo.transactions JOIN dbo.account ON account.Ac_no = transactions.ac_no
						                      JOIN dbo.customer ON customer.Cust_id = account.cust_id
						WHERE YEAR(t_date) = 2017 )



-- CÂU 21: Hiển thị những giao dịch trong mùa xuân của các chi nhánh miền trung. 
--         Gợi ý: giả sử một năm có 4 mùa, mỗi mùa kéo dài 3 tháng; chi nhánh miền trung có mã chi nhánh bắt đầu bằng VT.
select Branch.BR_id, transactions.t_id, t_type, t_amount, t_date, t_time 
from  Branch join customer     on customer.Br_id = Branch.BR_id
			 join  account     on customer.Cust_id=account.cust_id
			 join transactions on  account.Ac_no=transactions.ac_no 
where Branch.BR_id like 'VT%' and month(t_date) between 1 and 3


-- CÂU 22: Hiển thị họ tên và các giao dịch của KH sử dụng số điện thoại có 3 số đầu là 093 và 2 số cuối là 02.
-- cột: cust_name, t_id, cust_phone, t_amount
-- bảng: customer, transactions
-- đk: cust_phone có 3 số đầu 093 và 2 số cuối 02
SELECT customer.Cust_id, t_id, Cust_phone, t_amount, Cust_name AS TenKH
FROM dbo.account JOIN dbo.customer ON customer.Cust_id = account.cust_id
                 JOIN dbo.transactions ON transactions.ac_no = account.Ac_no
WHERE Cust_phone LIKE '093%02'



-- CÂU 23: Hãy liệt kê 2 chi nhánh làm việc kém hiệu quả nhất trong toàn hệ thống 
--         (số lượng giao dịch gửi tiền ít nhất) trong quý 3 năm 2017
select top 2 (count(t_amount)) , BR_name
from Branch join customer     on customer.Br_id = Branch.BR_id
			join  account     on customer.Cust_id=account.cust_id
			join transactions on  account.Ac_no=transactions.ac_no
where t_type = 1 and datepart(qq, t_date) =3 and year(t_date)=2017 
group by Branch.BR_id, BR_name
order by count(t_amount)


-- CÂU 24: Hãy liệt kê 2 chi nhánh có bận mải nhất hệ thống (thực hiện nhiều giao dịch gửi tiền nhất) trong năm 2017.
select top 2 (count(t_amount))  , BR_name
from Branch join customer     on customer.Br_id = Branch.BR_id
			join  account     on customer.Cust_id=account.cust_id
			join transactions on  account.Ac_no=transactions.ac_no
where t_type = 1 and year(t_date)=2017 
group by Branch.BR_id, BR_name
order by count(t_amount) DESC


-- CÂU 25: Tìm giao dịch gửi tiền nhiều nhất trong mùa đông. Nếu có thể, hãy đưa ra tên của người thực hiện GD và chi nhánh.
select top 1 (count(t_amount)) , BR_name
from Branch join customer     on customer.Br_id = Branch.BR_id
			join  account     on customer.Cust_id=account.cust_id
			join transactions on  account.Ac_no=transactions.ac_no
where t_type = 1 and year(t_date)=2017 
group by Branch.BR_id, BR_name
order by count(t_amount) DESC


-- CÂU 26: Để bổ sung nhân sự cho các chi nhánh, cần có kết quả phân tích về cường độ làm việc của họ. 
--         Hãy liệt kê những chi nhánh phải làm việc qua trưa và loại giao dịch là gửi tiền.
select distinct BR_name, t_time
from Branch join customer     on customer.Br_id = Branch.BR_id
			join  account     on customer.Cust_id=account.cust_id
			join transactions on  account.Ac_no=transactions.ac_no
where DATEPART(hh, t_time) between 11 and 13 and t_type=1


-- CÂU 27: Hãy liệt kê các giao dịch bất thường. Gợi ý: là các giao dịch gửi tiền những được thực hiện ngoài khung giờ làm việc 
--         và cho phép overtime (từ sau 16h đến trước 7h)
select t_id, t_amount, t_time
from transactions
where DATEPART(hh, t_time) between 11 and 13



-- CÂU 28: Hãy điều tra những giao dịch bất thường trong năm 2017. Giao dịch bất thường là giao dịch diễn ra trong 
--         khoảng thời gian từ 12h đêm tới 3 giờ sáng.
select t_id, t_amount, t_date, t_time
from transactions
where  (year( t_date) =2017 and(DATEPART(hh, t_time) = 12) )or( year( t_date) =2017 and(DATEPART(hh, t_time) between 1 and 2 ) )


-- CÂU 29: Có bao nhiêu người ở Đắc Lắc sở hữu nhiều hơn một tài khoản?
select customer.Cust_name, count( account.cust_id) N'Số lượng tài khoản'
from  customer join  account     on customer.Cust_id=account.cust_id
where Cust_ad  like N'%ĐĂK LĂK%' or Cust_ad  like N'%ĐĂKLĂK%'
group by customer.Cust_name,account.cust_id
having count( account.cust_id) >1


-- CÂU 30: Nếu mỗi giao dịch rút tiền ngân hàng thu phí 3.000 đồng, hãy tính xem tổng tiền phí thu được từ thu phí dịch vụ 
--         từ năm 2012 đến năm 2017 là bao nhiêu?
select count(t_id) * 3000 as N'Tổng tiền phí thu được'
from transactions
where (DATEPART(yy, t_date) between 2012 and 2017) and t_type= 0


-- CÂU 31: Hiển thị thông tin các khách hàng họ Trần theo các cột sau:
select customer.Cust_id N'Mã KH' , Cust_name N'Họ Tên', ac_balance as N'Số dư tài khoản' 
from customer join  account   on customer.Cust_id=account.cust_id
where Cust_name like N'Trần%'


-- CÂU 32: Cuối mỗi năm, nhiều khách hàng có xu hướng rút tiền khỏi ngân hàng để chuyển sang ngân hàng khác 
--         hoặc chuyển sang hình thức tiết kiệm khác. Hãy lọc những khách hàng có xu hướng rút tiền khỏi ngân hàng 
--         bằng hiển thị những người rút gần hết tiền trong tài khoản 
--         (tổng tiền rút trong tháng 12/2017 nhiều hơn 100 triệu và số dư trong tài khoản còn lại <= 100.000)
select Cust_name
from customer join  account      on customer.Cust_id=account.cust_id
			  join transactions  on  account.Ac_no=transactions.ac_no
where month(t_date) =2 and year(t_date)=2017 
group by Cust_name


-- CÂU 33: Thời gian vừa qua, hệ thống CSDL của ngân hàng bị hacker tấn công (giả sử tí cho vui J), 
--         tổng tiền trong tài khoản bị thay đổi bất thường. Hãy liệt kê những tài khoản bất thường đó. 
--         Gợi ý: tài khoản bất thường là tài khoản có tổng tiền gửi – tổng tiền rút <> số tiền trong tài khoản
select distinct Cust_name
from   customer join  account      on customer.Cust_id=account.cust_id
			  join transactions    on  account.Ac_no=transactions.ac_no
where	account.ac_balance <>
		(  (select sum(t_amount)
			from transactions
			where t_type=1)
		-
			(select sum(t_amount)
			 from transactions
			 where t_type=0))


-- CÂU 34: Do hệ thống mạng bị nghẽn và hệ thống xử lý chưa tốt phần điều khiển đa người dùng nên một số tài khoản bị invalid. 
--         Hãy liệt kê những tài khoản đó. Gợi ý: tài khoản bị invalid là những tài khoản có số tiền âm. 
--         Nếu có thể hãy liệt kê giao dịch gây ra sự cố tài khoản âm. Giao dịch đó được thực hiện ở chi nhánh nào? 
--         (mục đích để quy kết trách nhiệm J)
select Cust_name,account.Ac_no,ac_balance, t_id, t_amount, t_date, BR_name
from Branch join customer     on customer.Br_id = Branch.BR_id
			join  account     on customer.Cust_id=account.cust_id
			join transactions on  account.Ac_no=transactions.ac_no
where ac_balance <0


-- CÂU 35: (Giả sử) Gần đây, một số khách hàng ở chi nhánh Đà Nẵng kiện rằng: 
--         tổng tiền trong tài khoản không khớp với số tiền họ thực hiện giao dịch. Hãy điều tra sự việc này bằng cách 
--         hiển thị danh sách khách hàng ở Đà Nẵng bao gồm các thông tin sau: 
--         mã khách hàng, họ tên khách hàng, tổng tiền đang có trong tài khoản, tổng tiền đã gửi, tổng tiền đã rút, 
--         kết luận (nếu tổng tiền gửi – tổng tiền rút = số tiền trong tài khoản à OK, trường hợp còn lại à có sai)


-- CÂU 36: Ngân hàng cần biết những chi nhánh nào có nhiều giao dịch rút tiền vào buổi chiều để chuẩn bị chuyển tiền tới. 
--         Hãy liệt kê danh sách các chi nhánh và lượng tiền rút trung bình theo ngày (chỉ xét những giao dịch diễn ra trong buổi chiều)
--         ,sắp xếp giảm giần theo lượng tiền giao dịch.