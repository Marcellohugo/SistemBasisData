-- No.1
SELECT
    P.NIK,
    P.Nama AS Customer_Name,
    P.Asal_Kota AS Customer_City
FROM
    Pelanggan P
JOIN
    Membership M ON P.Membership_ID = M.ID
JOIN
    Transaksi T ON P.NIK = T.Pelanggan_NIK
WHERE
    T.Waktu_Mulai > '2023-01-01 08:00:00';

-- No.2
SELECT
    C.*,
    COUNT(T.ID) AS Transaction_Count
FROM
    Cabang C
LEFT JOIN
    Transaksi T ON C.ID = T.Cabang_ID
GROUP BY
    C.ID, C.Alamat, C.Kecamatan, C.Tanggal_Pembukaan;

-- No.3
SELECT
    P.NIK,
    P.Nama AS Customer_Name,
    P.Asal_Kota AS Customer_City,
    P.Usia
FROM
    Pelanggan P
JOIN
    Membership M ON P.Membership_ID = M.ID
WHERE
    P.Usia > (
        SELECT
            AVG(TIMESTAMPDIFF(YEAR, Tanggal_Lahir, CURDATE()))
        FROM
            Pegawai
    );

-- No.4
SELECT
    T.Cabang_ID AS Branch_ID,
    COUNT(T.ID) AS Transaction_Count,
    GROUP_CONCAT(S.ID) AS Bike_IDs
FROM
    Transaksi T
JOIN
    Sepeda S ON T.Sepeda_ID = S.ID
JOIN (
    SELECT
        Cabang_ID,
        Sepeda_ID,
        COUNT(*) AS Brand_Transaction_Count
    FROM
        Transaksi
    JOIN
        Sepeda ON Transaksi.Sepeda_ID = Sepeda.ID
    GROUP BY
        Cabang_ID, Sepeda_ID
) AS BrandTransactionCount ON T.Cabang_ID = BrandTransactionCount.Cabang_ID
    AND T.Sepeda_ID = BrandTransactionCount.Sepeda_ID
WHERE
    BrandTransactionCount.Brand_Transaction_Count = (
        SELECT
            MAX(Brand_Transaction_Count)
        FROM
            (
                SELECT
                    Cabang_ID,
                    Sepeda_ID,
                    COUNT(*) AS Brand_Transaction_Count
                FROM
                    Transaksi
                JOIN
                    Sepeda ON Transaksi.Sepeda_ID = Sepeda.ID
                GROUP BY
                    Cabang_ID, Sepeda_ID
            ) AS MaxBrandTransaction
        WHERE
            MaxBrandTransaction.Cabang_ID = BrandTransactionCount.Cabang_ID
    )
GROUP BY
    T.Cabang_ID;

-- No.5
SELECT
    P.Nama AS Customer_Name,
    P.Membership_ID,
    COUNT(T.ID) AS Total_Transactions
FROM
    Pelanggan P
JOIN
    Transaksi T ON P.NIK = T.Pelanggan_NIK
JOIN
    Membership M ON P.Membership_ID = M.ID
WHERE
    M.Tanggal_Pendaftaran = T.Tanggal_Sewa
GROUP BY
    P.Nama, P.Membership_ID
ORDER BY
    Total_Transactions DESC;

-- No.6
SELECT
    P.Nama AS 'Employee Name',
    P.Tanggal_Mulai_Bekerja AS 'Start Date',
    COUNT(T.ID) AS 'Number of Transactions'
FROM
    Pegawai P
JOIN Transaksi T ON P.ID = T.Pegawai_ID
WHERE
    YEAR(P.Tanggal_Mulai_Bekerja) = 2023
GROUP BY
    P.ID, P.Nama, P.Tanggal_Mulai_Bekerja
ORDER BY
    P.Tanggal_Mulai_Bekerja;

-- No.7
SELECT
    s.Jenis AS Bike_Type,
    COUNT(t.ID) AS Number_of_Bikes_Rented
FROM
    Transaksi t
    JOIN Sepeda s ON t.Sepeda_ID = s.ID
WHERE
    MONTH(t.Tanggal_Sewa) = MONTH(CURRENT_DATE())
GROUP BY
    s.Jenis;

-- No.8
SELECT 
    P.Nama AS Customer_Name,
    P.Nomor_Telepon AS Phone_Number,
    PL.Membership_ID
FROM 
    Pelanggan P
JOIN 
    Transaksi T ON P.NIK = T.Pelanggan_NIK
JOIN 
    Sepeda S ON T.Sepeda_ID = S.ID
JOIN 
    Pelanggan PL ON P.NIK = PL.NIK
WHERE 
    S.Jenis = 'Gunung'
GROUP BY 
    P.NIK
HAVING 
    COUNT(T.ID) > 1;

-- No.9
SELECT
    Transaksi.ID AS Transaction_ID,
    Transaksi.Tanggal_Sewa AS Rental_Date,
    TIMESTAMPDIFF(HOUR, Transaksi.Waktu_Mulai, Transaksi.Waktu_Selesai) AS Rental_Duration,
    Sepeda.Jenis AS Bike_Type,
    (TIMESTAMPDIFF(HOUR, Transaksi.Waktu_Mulai, Transaksi.Waktu_Selesai) * Sepeda.Harga_Sewa_Per_Jam) AS Total_Rental_Cost
FROM
    Transaksi
JOIN Sepeda ON Transaksi.Sepeda_ID = Sepeda.ID
WHERE
    TIMESTAMPDIFF(HOUR, Transaksi.Waktu_Mulai, Transaksi.Waktu_Selesai) >
    (SELECT AVG(TIMESTAMPDIFF(HOUR, Waktu_Mulai, Waktu_Selesai)) FROM transaksi);

-- No.10
SELECT Cabang_ID, COUNT(ID) AS Jumlah_Transaksi
FROM Transaksi
GROUP BY Cabang_ID
HAVING Jumlah_Transaksi = (
    SELECT MIN(Jumlah_Transaksi)
    FROM (
        SELECT Cabang_ID, COUNT(ID) AS Jumlah_Transaksi
        FROM Transaksi
        GROUP BY Cabang_ID
    ) AS TempTable
);
