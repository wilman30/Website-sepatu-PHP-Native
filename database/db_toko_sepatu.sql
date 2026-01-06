-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 06 Jun 2023 pada 06.37
-- Versi server: 10.4.27-MariaDB
-- Versi PHP: 8.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_toko_sepatu`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `dashboard` ()   BEGIN
    DECLARE jumlah_produk INT;
    DECLARE jumlah_supplier INT;
    DECLARE jumlah_stok INT;
    DECLARE jumlah_user INT;
    DECLARE jumlah_pendapatan INT;    
    DECLARE jumlah_lunas INT;
    DECLARE jumlah_belum_bayar INT;
    DECLARE jumlah_diproses INT;
    DECLARE jumlah_dikirim INT;
    DECLARE jumlah_pesanan_bulan INT;
    DECLARE jumlah_pendapatan_bulan INT;
    
    
    SELECT COUNT(*) INTO jumlah_produk FROM tb_produk;
    SELECT COUNT(*) INTO jumlah_supplier FROM tb_suplier;
    SELECT SUM(total_stok) INTO jumlah_stok FROM tb_produk;
    SELECT COUNT(*) INTO jumlah_user FROM tb_users WHERE id_user NOT LIKE '%ADM%';
    SELECT SUM(total_harga_pesanan) INTO jumlah_pendapatan FROM tb_pesanan;
    SELECT COUNT(*) INTO jumlah_lunas FROM tb_pesanan WHERE STATUS='dibayar';
    SELECT COUNT(*) INTO jumlah_belum_bayar FROM tb_pesanan WHERE STATUS='pending';
    SELECT COUNT(*) INTO jumlah_diproses FROM tb_pesanan WHERE STATUS='diproses';
    SELECT COUNT(*) INTO jumlah_dikirim FROM tb_pesanan WHERE STATUS='sedang dikirim';
    SELECT COUNT(*), SUM(total_harga_pesanan) INTO jumlah_pesanan_bulan, jumlah_pendapatan_bulan FROM tb_pesanan
    WHERE MONTH(tgl_pesanan) = MONTH(CURRENT_DATE()) AND YEAR(tgl_pesanan) = YEAR(CURRENT_DATE()) and STATUS!='pending';    
    
    SELECT jumlah_produk, jumlah_supplier, jumlah_stok, jumlah_user, jumlah_pendapatan, jumlah_lunas, 
           jumlah_belum_bayar, jumlah_diproses, jumlah_dikirim, jumlah_pesanan_bulan, jumlah_pendapatan_bulan;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_id` (IN `data_table` VARCHAR(50))   BEGIN
    DECLARE id INT;
    DECLARE str VARCHAR(255);
    DECLARE panjang_angka_id INT;
    
    if data_table = 'produk' then
    
	    SELECT CAST(SUBSTRING(id_produk, 4, 3) AS INT) INTO id FROM tb_produk ORDER BY id_produk DESC LIMIT 1;
	    
	    SET id = id + 1;
	    SET panjang_angka_id = CHAR_LENGTH(id);
	    
	    IF panjang_angka_id > 2 THEN
		SET str = CONCAT('SPT', id);
	    ELSEIF panjang_angka_id > 1 THEN 
		SET str = CONCAT('SPT0', id);
	    ELSE
		SET str = CONCAT('SPT00', id);
	    END IF;
	    
    elseif data_table = 'pelanggan' then 
    
	    SELECT CAST(SUBSTRING(id_user, 4, 3) AS INT) INTO id FROM tb_users ORDER BY id_user DESC LIMIT 1;
	    
	    SET id = id + 1;
	    SET panjang_angka_id = CHAR_LENGTH(id);
	    
	    IF panjang_angka_id > 2 THEN
		SET str = CONCAT('PLG', id);
	    ELSEIF panjang_angka_id > 1 THEN 
		SET str = CONCAT('PLG0', id);
	    ELSE
		SET str = CONCAT('PLG00', id);
	    END IF;
    
    ELSEIF data_table = 'suplier' THEN 
    
	    SELECT CAST(SUBSTRING(id_suplier, 4, 3) AS INT) INTO id FROM tb_suplier ORDER BY id_suplier DESC LIMIT 1;
	    
	    SET id = id + 1;
	    SET panjang_angka_id = CHAR_LENGTH(id);
	    
	    IF panjang_angka_id > 2 THEN
		SET str = CONCAT('SUP', id);
	    ELSEIF panjang_angka_id > 1 THEN 
		SET str = CONCAT('SUP0', id);
	    ELSE
		SET str = CONCAT('SUP00', id);
	    END IF;
	    
    end if;
    
    SELECT str AS id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `login` (IN `username` VARCHAR(50), IN `passwordd` VARCHAR(255))   BEGIN
	declare login int;
	declare txtnama varchar(255);
	declare txtid_user varchar(11);
	
	SELECT count(*), nama, id_user into login, txtnama, txtid_user  FROM tb_users u WHERE u.username = username AND u.password = passwordd;
	if login < 1 then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username / Password Salah!!';
	end if;
	
	SELECT txtnama, txtid_user;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `no_urut` ()   BEGIN
    DECLARE i INT DEFAULT 1;

    -- Loop menggunakan WHILE
    WHILE i <= 10 DO
        -- Tampilkan nilai i
        SELECT i;

        -- Tambahkan 1 ke nilai i
        SET i = i + 1;
    END WHILE;
    
    select i;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `remove_keranjang` (IN `id_produkk` VARCHAR(11), IN `id_userr` VARCHAR(11), IN `ukurann` INT)   BEGIN
    DECLARE jumlah_data INT;
    
    SELECT COUNT(*) INTO jumlah_data FROM tb_keranjang 
    WHERE id_produk = id_produkk AND id_user = id_userr AND ukuran = ukurann;
    
    IF jumlah_data > 0 THEN
        DELETE FROM tb_keranjang WHERE id_produk = id_produkk AND id_user = id_userr AND ukuran = ukurann;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `show_detail_produk` (IN `id` VARCHAR(50))   BEGIN

 SELECT * FROM tb_produk p 
 INNER JOIN tb_detail_produk dp ON p.id_produk = dp.id_produk 
 INNER JOIN tb_suplier s ON s.id_suplier = p.id_suplier
 WHERE p.id_produk = id and dp.stok > 0;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `tambah_keranjang` (IN `id_user` VARCHAR(11), IN `id_produk` VARCHAR(11), IN `ukuran` INT, IN `jumlah` INT)   BEGIN
    DECLARE cek_id_produk VARCHAR(11);
    
    -- cek apakah id produk sudah ada
    SELECT id_produk INTO cek_id_produk FROM tb_keranjang k 
    WHERE k.id_produk = id_produk and k.ukuran = ukuran and k.id_user = id_user;
    
    IF (cek_id_produk IS NULL) THEN
        -- masukkan data ke tabel pesanan
        INSERT INTO tb_keranjang values('', id_user, id_produk, ukuran, jumlah);
    else 
        update tb_keranjang k set k.jumlah = k.jumlah + jumlah 
        where k.id_produk = id_produk and k.id_user = id_user;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `tambah_pesanan` (IN `id_pesanann` VARCHAR(11), IN `id_users` VARCHAR(11), IN `id_produk` VARCHAR(11), IN `id_bank` INT, IN `jumlah` INT, IN `ukuran` INT)   BEGIN
    DECLARE harga_produk INT;
    DECLARE total_pesan INT;
    DECLARE cek_id_pesanan VARCHAR(11);
    
    -- ambil dulu harga produknya dan cek apakah id pesanan sudah ada
    SELECT harga INTO harga_produk FROM tb_produk p WHERE p.id_produk = id_produk;
    SELECT id_pesanan INTO cek_id_pesanan FROM tb_pesanan WHERE id_pesanan = id_pesanann;
    
    IF (cek_id_pesanan IS NULL) THEN
        -- masukkan data ke tabel pesanan
        INSERT INTO tb_pesanan (id_pesanan, id_users, id_bank, tgl_pesanan) VALUES (id_pesanann, id_users, id_bank, CURDATE());
    END IF;
    
    -- tambahkan data pesanan detail
    INSERT INTO tb_detail_pesanan (id_detail_pesanan, id_pesanan, id_produk, jumlah, total_harga, ukuran) 
    VALUES (NULL, id_pesanann, id_produk, jumlah, harga_produk * jumlah, ukuran);
    
    SELECT SUM(total_harga) INTO total_pesan FROM tb_detail_pesanan WHERE id_pesanan = id_pesanann;
    
    UPDATE tb_pesanan SET total_harga_pesanan=total_pesan WHERE id_pesanan = id_pesanann;
    
      
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `tambah_stok` (IN `id_produk` VARCHAR(11), IN `ukuran` INT, IN `stok_tambah` INT)   BEGIN

 UPDATE tb_detail_produk dp set dp.stok = dp.stok + stok_tambah 
 where dp.id_produk=id_produk and dp.ukuran = ukuran;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_stok_total` (IN `id_produk` VARCHAR(11))   BEGIN
    declare total_semua_stok int;
    
    select sum(stok) into total_semua_stok from tb_detail_produk dp where dp.id_produk=id_produk;
    
    update tb_produk p set p.total_stok=total_semua_stok where p.id_produk=id_produk;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_user` (IN `id_users` VARCHAR(11), IN `nama` VARCHAR(50), IN `username` VARCHAR(50), IN `passwordd` VARCHAR(255), IN `alamat` VARCHAR(100), IN `email` VARCHAR(50), IN `no_telp` VARCHAR(13))   BEGIN
    IF (passwordd = '') THEN
	UPDATE tb_users SET nama=nama, username=username, alamat=alamat,
	email=email, no_telp=no_telp WHERE id_user=id_users;
    ELSE
	UPDATE tb_users us SET nama=nama, username=username, password=passwordd, alamat=alamat,
	email=email, no_telp=no_telp WHERE id_user=id_users;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `tampil_keranjang`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `tampil_keranjang` (
`id_keranjang` int(11)
,`id_user` varchar(11)
,`id_produk` varchar(11)
,`ukuran` int(11)
,`jumlah` int(11)
,`nama` varchar(50)
,`alamat` varchar(100)
,`no_telp` varchar(13)
,`nama_produk` varchar(50)
,`harga` int(11)
,`gambar` varchar(255)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `tampil_list_pesanan`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `tampil_list_pesanan` (
`id_pesanan` varchar(11)
,`id_users` varchar(11)
,`tgl_pesanan` date
,`total_harga_pesanan` int(11)
,`nama_produk` varchar(50)
,`ukuran` int(11)
,`jumlah` int(11)
,`total_harga` int(11)
,`status` enum('pending','dibayar','diproses','sedang dikirim','selesai')
,`gambar` varchar(255)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `tampil_pembayaran`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `tampil_pembayaran` (
`id_pembayaran` int(11)
,`id_pesanan` varchar(11)
,`tgl_dibayar` date
,`bukti_pembayaran` varchar(255)
,`tgl_pesanan` date
,`total_harga_pesanan` int(11)
,`nama_bank` varchar(11)
,`nama` varchar(50)
,`no_rekening` varchar(20)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `tampil_pesanan`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `tampil_pesanan` (
`id_pesanan` varchar(11)
,`id_users` varchar(11)
,`id_bank` int(11)
,`tgl_pesanan` date
,`total_harga_pesanan` int(11)
,`status` enum('pending','dibayar','diproses','sedang dikirim','selesai')
,`nama_bank` varchar(11)
,`no_rekening` varchar(20)
,`nama` varchar(50)
,`alamat` varchar(100)
,`no_telp` varchar(13)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `tampil_produk`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `tampil_produk` (
`id_produk` varchar(11)
,`id_suplier` varchar(11)
,`nama_produk` varchar(50)
,`merek` varchar(20)
,`kategori` varchar(20)
,`harga` int(11)
,`total_stok` int(11)
,`warna` varchar(100)
,`deskripsi` text
,`gambar` varchar(255)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `tampil_produk_terbaru`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `tampil_produk_terbaru` (
`id_produk` varchar(11)
,`nama_produk` varchar(50)
,`gambar` varchar(255)
,`harga` int(11)
,`deskripsi` text
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_bank_bayar`
--

CREATE TABLE `tb_bank_bayar` (
  `id_bank` int(11) NOT NULL,
  `nama_bank` varchar(11) NOT NULL,
  `no_rekening` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_bank_bayar`
--

INSERT INTO `tb_bank_bayar` (`id_bank`, `nama_bank`, `no_rekening`) VALUES
(1, 'BNI', '0179383938393'),
(2, 'BRI', '0317383938393'),
(3, 'BTN', '0473839382930');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_detail_pesanan`
--

CREATE TABLE `tb_detail_pesanan` (
  `id_detail_pesanan` int(11) NOT NULL,
  `id_pesanan` varchar(11) NOT NULL,
  `id_produk` varchar(11) NOT NULL,
  `jumlah` int(11) NOT NULL,
  `total_harga` int(11) DEFAULT 0,
  `ukuran` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_detail_pesanan`
--

INSERT INTO `tb_detail_pesanan` (`id_detail_pesanan`, `id_pesanan`, `id_produk`, `jumlah`, `total_harga`, `ukuran`) VALUES
(66, '647a540e29b', 'SPT003', 2, 1000000, 40),
(67, '647aa1432a6', 'SPT001', 2, 500000, 37),
(68, '647aac9b038', 'SPT001', 2, 500000, 35),
(69, '647aacb6d73', 'SPT004', 3, 900000, 40),
(70, '647ab3e2a3e', 'SPT001', 1, 250000, 35),
(71, '647eb4772ec', 'SPT010', 1, 100000, 40),
(72, '647eb6669d2', 'SPT001', 1, 250000, 36);

--
-- Trigger `tb_detail_pesanan`
--
DELIMITER $$
CREATE TRIGGER `stok_sepatu_kurang` AFTER INSERT ON `tb_detail_pesanan` FOR EACH ROW BEGIN
    update tb_detail_produk set stok = stok - new.jumlah where id_produk = new.id_produk and ukuran = new.ukuran;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_detail_produk`
--

CREATE TABLE `tb_detail_produk` (
  `id_produk` varchar(11) NOT NULL,
  `ukuran` int(11) NOT NULL,
  `stok` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_detail_produk`
--

INSERT INTO `tb_detail_produk` (`id_produk`, `ukuran`, `stok`) VALUES
('SPT001', 35, 25),
('SPT001', 36, 16),
('SPT001', 37, 18),
('SPT001', 38, 10),
('SPT003', 40, 0),
('SPT003', 42, 1),
('SPT004', 40, 97),
('SPT005', 39, 9),
('SPT005', 40, 7),
('SPT005', 41, 10),
('SPT005', 42, 10),
('SPT005', 43, 9),
('SPT009', 40, 19),
('SPT010', 40, 19),
('SPT011', 35, 10),
('SPT012', 38, 1);

--
-- Trigger `tb_detail_produk`
--
DELIMITER $$
CREATE TRIGGER `cek_insert_ukuran` BEFORE INSERT ON `tb_detail_produk` FOR EACH ROW begin
    DECLARE id_produk_old VARCHAR(20);
    DECLARE ukuran_old VARCHAR(20);
    
    SET id_produk_old = '';
    SET ukuran_old = '';
    
    SELECT id_produk, ukuran INTO id_produk_old, ukuran_old 
    FROM tb_detail_produk WHERE id_produk = new.id_produk AND ukuran = new.ukuran;
    
   IF (id_produk_old = new.id_produk AND ukuran_old = new.ukuran)  THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ukuran Yang Kamu Input Sudah ada!!';
   END IF;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_semua_stok_delete` AFTER DELETE ON `tb_detail_produk` FOR EACH ROW BEGIN
    CALL update_stok_total(old.id_produk);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_semua_stok_insert` AFTER INSERT ON `tb_detail_produk` FOR EACH ROW BEGIN
    call update_stok_total(new.id_produk);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_semua_stok_update` AFTER UPDATE ON `tb_detail_produk` FOR EACH ROW BEGIN
    CALL update_stok_total(new.id_produk);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_keranjang`
--

CREATE TABLE `tb_keranjang` (
  `id_keranjang` int(11) NOT NULL,
  `id_user` varchar(11) NOT NULL,
  `id_produk` varchar(11) NOT NULL,
  `ukuran` int(11) NOT NULL,
  `jumlah` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_keranjang`
--

INSERT INTO `tb_keranjang` (`id_keranjang`, `id_user`, `id_produk`, `ukuran`, `jumlah`) VALUES
(36, 'PLG021', 'SPT001', 35, 2);

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_pembayaran`
--

CREATE TABLE `tb_pembayaran` (
  `id_pembayaran` int(11) NOT NULL,
  `id_pesanan` varchar(11) NOT NULL,
  `tgl_dibayar` date NOT NULL,
  `bukti_pembayaran` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_pembayaran`
--

INSERT INTO `tb_pembayaran` (`id_pembayaran`, `id_pesanan`, `tgl_dibayar`, `bukti_pembayaran`) VALUES
(9, '647aacb6d73', '2023-06-03', '647aacc11abad4.51083611.png');

--
-- Trigger `tb_pembayaran`
--
DELIMITER $$
CREATE TRIGGER `update_pesanan_dibayar` AFTER INSERT ON `tb_pembayaran` FOR EACH ROW BEGIN
    update tb_pesanan p set p.status='dibayar' where p.id_pesanan = new.id_pesanan;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_pesanan`
--

CREATE TABLE `tb_pesanan` (
  `id_pesanan` varchar(11) NOT NULL,
  `id_users` varchar(11) NOT NULL,
  `id_bank` int(11) NOT NULL,
  `tgl_pesanan` date NOT NULL,
  `total_harga_pesanan` int(11) NOT NULL,
  `status` enum('pending','dibayar','diproses','sedang dikirim','selesai') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_pesanan`
--

INSERT INTO `tb_pesanan` (`id_pesanan`, `id_users`, `id_bank`, `tgl_pesanan`, `total_harga_pesanan`, `status`) VALUES
('647a540e29b', 'PLG021', 1, '2023-06-03', 1000000, 'pending'),
('647aa1432a6', 'PLG021', 1, '2023-06-03', 500000, 'diproses'),
('647aac9b038', 'PLG021', 1, '2023-06-03', 500000, 'pending'),
('647aacb6d73', 'PLG021', 2, '2023-06-03', 900000, 'dibayar'),
('647ab3e2a3e', 'PLG021', 2, '2023-06-03', 250000, 'pending'),
('647eb4772ec', 'PLG021', 2, '2023-06-06', 100000, 'pending'),
('647eb6669d2', 'PLG021', 2, '2023-06-06', 250000, 'pending');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_produk`
--

CREATE TABLE `tb_produk` (
  `id_produk` varchar(11) NOT NULL,
  `id_suplier` varchar(11) NOT NULL,
  `nama_produk` varchar(50) NOT NULL,
  `merek` varchar(20) NOT NULL,
  `kategori` varchar(20) NOT NULL,
  `harga` int(11) NOT NULL,
  `total_stok` int(11) NOT NULL DEFAULT 0,
  `warna` varchar(100) NOT NULL,
  `deskripsi` text NOT NULL,
  `gambar` varchar(255) NOT NULL DEFAULT 'foto.jpg'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_produk`
--

INSERT INTO `tb_produk` (`id_produk`, `id_suplier`, `nama_produk`, `merek`, `kategori`, `harga`, `total_stok`, `warna`, `deskripsi`, `gambar`) VALUES
('SPT001', 'SUP001', 'Sepatu Casual 2', 'ABC Shoes', 'Sepatu Pria', 250000, 69, 'Hitam', 'Sepatu casual dengan desain modern. Sepatu casual dengan desain modern. Sepatu casual dengan desain modern. Sepatu casual dengan desain modern. ', '647a482c6458e5.55904622.png'),
('SPT003', 'SUP002', 'Sepatu Formal 1', 'DEF Footwear', 'Sepatu Pria', 500000, 1, 'Coklat', 'Sepatu formal untuk acara resmi brow', '6478927572e9e2.32190198.png'),
('SPT004', 'SUP001', 'Sepatu Sneakers 1', 'PQR Sneakers', 'Sepatu Pria', 300000, 97, 'Putih', 'Sepatu sneakers dengan desain trendy. Sepatu sneakers dengan desain trendy. Sepatu sneakers dengan desain trendy. Sepatu sneakers dengan desain trendy', '6478941ab74bf0.03041541.png'),
('SPT005', 'SUP002', 'Sepatu Casual 1', 'Casual', 'Sepatu Pria', 450000, 45, 'Hijau', 'Sepatu khusus untuk lari dengan kenyamanan maksimal. Sepatu khusus untuk lari dengan kenyamanan maksimal. Sepatu khusus untuk lari dengan kenyamanan maksimal', '647893348532a2.64184681.png'),
('SPT009', 'SUP003', 'Sepatu Slip-On 1', 'UVW Slip-On', 'Sepatu Pria', 280000, 19, 'Hitam', 'Sepatu slip-on yang praktis dan stylish. Sepatu slip-on yang praktis dan stylish. Sepatu slip-on yang praktis dan stylish. Sepatu slip-on yang praktis dan stylish', '64789454c6a9c4.42447607.png'),
('SPT010', 'SUP005', 'High Heels 1', 'bebas', 'Sepatu Betina', 100000, 19, 'Hitam', 'ini sepatu high heels. ini sepatu high heels. ini sepatu high heels. ini sepatu high heels. ini sepatu high heels. ini sepatu high heels.', '647a4ae5dd6c85.40089214.png'),
('SPT011', 'SUP004', 'Wedges 1', 'bebas', 'Sepatu Betina', 50000, 10, 'merah', 'sepatu betina. sepatu betina. sepatu betina. sepatu betina. sepatu betina. sepatu betina. sepatu betina.sepatu betina.', '647a4bde69f5d6.75966402.png'),
('SPT012', 'SUP001', 'High Heels 2', 'Bebas', 'Sepatu Pria', 10000000, 1, 'Hitam', 'coba', '647ab22c678f42.14994801.png');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_suplier`
--

CREATE TABLE `tb_suplier` (
  `id_suplier` varchar(11) NOT NULL,
  `nama_suplier` varchar(50) NOT NULL,
  `alamat` varchar(100) NOT NULL,
  `no_telp` varchar(13) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_suplier`
--

INSERT INTO `tb_suplier` (`id_suplier`, `nama_suplier`, `alamat`, `no_telp`) VALUES
('SUP001', 'Suplier A', 'Jl. Raya No. 1234', '081234567898'),
('SUP002', 'Suplier B', 'Jl. Utama No. 456', '08234567890'),
('SUP003', 'Suplier C', 'Jl. Maju Mundur No. 789', '08345678901'),
('SUP004', 'Suplier D', 'Jl. Sejahtera No. 234', '08456789012'),
('SUP005', 'Suplier E', 'Jl. Damai No. 567', '08567890123'),
('SUP006', 'Suplier F', 'Jl. Harapan No. 890', '08678901234'),
('SUP007', 'Suplier G', 'Jl. Bahagia No. 123', '08789012345'),
('SUP008', 'Suplier H', 'Jl. Makmur No. 456', '08890123456'),
('SUP009', 'Suplier I', 'Jl. Indah No. 789', '08901234567'),
('SUP010', 'Suplier J', 'Jl. Serasi No. 234', '09012345678');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_users`
--

CREATE TABLE `tb_users` (
  `id_user` varchar(11) NOT NULL,
  `nama` varchar(50) NOT NULL,
  `username` varchar(45) NOT NULL,
  `password` varchar(255) NOT NULL,
  `alamat` varchar(100) NOT NULL,
  `email` varchar(40) NOT NULL,
  `no_telp` varchar(13) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_users`
--

INSERT INTO `tb_users` (`id_user`, `nama`, `username`, `password`, `alamat`, `email`, `no_telp`) VALUES
('ADM001', 'WILMAN', 'admin', 'admin', 'Jl. Bahagia No. 444', 'abdwkhd@example.com', '091234567897'),
('PLG001', 'Anitaaa', 'anita01', '12345', 'Jl. Merdeka No. 10, Jakarta', 'anita01@example.com', '081234567891'),
('PLG002', 'Budi', 'budi02', 'password2', 'Jl. Raya Surabaya No. 5, Surabaya', 'budi02@example.com', '081234567892'),
('PLG003', 'Citra', 'citra03', 'password3', 'Jl. Cikutra Indah No. 15, Bandung', 'citra03@example.com', '081234567893'),
('PLG004', 'Dewi', 'dewi04', 'password4', 'Jl. Medan Baru No. 20, Medan', 'dewi04@example.com', '081234567894'),
('PLG005', 'Eko', 'eko05', 'password5', 'Jl. Gajah Mada No. 25, Semarang', 'eko05@example.com', '081234567895'),
('PLG006', 'Fira', 'fira06', 'password6', 'Jl. Jendral Sudirman No. 30, Surabaya', 'fira06@example.com', '081234567896'),
('PLG007', 'Gita', 'gita07', 'password7', 'Jl. Diponegoro No. 35, Yogyakarta', 'gita07@example.com', '081234567897'),
('PLG008', 'Hadi', 'hadi08', 'password8', 'Jl. Ahmad Yani No. 40, Bandung', 'hadi08@example.com', '081234567898'),
('PLG009', 'Indra', 'indra09', 'password9', 'Jl. Darmo Permai No. 45, Surabaya', 'indra09@example.com', '081234567899'),
('PLG010', 'Joko', 'joko10', 'password10', 'Jl. Sudirman No. 50, Jakarta', 'joko10@example.com', '081234567890'),
('PLG011', 'Kartika', 'kartika11', 'password11', 'Jl. Ganesha No. 55, Bandung', 'kartika11@example.com', '081234567891'),
('PLG012', 'Lukman', 'lukman12', 'password12', 'Jl. Hayam Wuruk No. 60, Jakarta', 'lukman12@example.com', '081234567892'),
('PLG013', 'Maya', 'maya13', 'password13', 'Jl. Merpati No. 65, Medan', 'maya13@example.com', '081234567893'),
('PLG014', 'Nadia', 'nadia14', 'password14', 'Jl. Asia Afrika No. 70, Bandung', 'nadia14@example.com', '081234567894'),
('PLG015', 'Oscar', 'oscar15', 'password15', 'Jl. Thamrin No. 75, Jakarta', 'oscar15@example.com', '081234567895'),
('PLG016', 'Putri', 'putri16', 'password16', 'Jl. Ahmad Dahlan No. 80, Yogyakarta', 'putri16@example.com', '081234567896'),
('PLG017', 'Rudi', 'rudi17', 'password17', 'Jl. Gatot Subroto No. 85, Jakarta', 'rudi17@example.com', '081234567897'),
('PLG018', 'Siska', 'siska18', 'password18', 'Jl. Diponegoro No. 90, Semarang', 'siska18@example.com', '081234567898'),
('PLG019', 'Tono', 'tono19', 'password19', 'Jl. Sudirman No. 95, Medan', 'tono19@example.com', '081234567899'),
('PLG020', 'Vina', 'vina20', 'password20', 'Jl. Gajah Mada No. 100, Surabaya', 'vina20@example.com', '081234567890'),
('PLG021', 'azrel', 'azrel', '123', 'Jl. Gatot Subroto No. 85, Jakarta', 'lkjh@ljkhklj.com', '098790873294');

--
-- Trigger `tb_users`
--
DELIMITER $$
CREATE TRIGGER `update_password` BEFORE UPDATE ON `tb_users` FOR EACH ROW BEGIN
    IF new.password = '' THEN
	update tb_users set old.password = old.password where id_users = new.id_user;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur untuk view `tampil_keranjang`
--
DROP TABLE IF EXISTS `tampil_keranjang`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tampil_keranjang`  AS SELECT `k`.`id_keranjang` AS `id_keranjang`, `k`.`id_user` AS `id_user`, `k`.`id_produk` AS `id_produk`, `k`.`ukuran` AS `ukuran`, `k`.`jumlah` AS `jumlah`, `u`.`nama` AS `nama`, `u`.`alamat` AS `alamat`, `u`.`no_telp` AS `no_telp`, `p`.`nama_produk` AS `nama_produk`, `p`.`harga` AS `harga`, `p`.`gambar` AS `gambar` FROM ((`tb_keranjang` `k` join `tb_produk` `p` on(`k`.`id_produk` = `p`.`id_produk`)) join `tb_users` `u` on(`k`.`id_user` = `u`.`id_user`))  ;

-- --------------------------------------------------------

--
-- Struktur untuk view `tampil_list_pesanan`
--
DROP TABLE IF EXISTS `tampil_list_pesanan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tampil_list_pesanan`  AS SELECT `psn`.`id_pesanan` AS `id_pesanan`, `psn`.`id_users` AS `id_users`, `psn`.`tgl_pesanan` AS `tgl_pesanan`, `psn`.`total_harga_pesanan` AS `total_harga_pesanan`, `p`.`nama_produk` AS `nama_produk`, `dp`.`ukuran` AS `ukuran`, `dp`.`jumlah` AS `jumlah`, `dp`.`total_harga` AS `total_harga`, `psn`.`status` AS `status`, `p`.`gambar` AS `gambar` FROM ((`tb_pesanan` `psn` join `tb_detail_pesanan` `dp` on(`psn`.`id_pesanan` = `dp`.`id_pesanan`)) join `tb_produk` `p` on(`dp`.`id_produk` = `p`.`id_produk`))  ;

-- --------------------------------------------------------

--
-- Struktur untuk view `tampil_pembayaran`
--
DROP TABLE IF EXISTS `tampil_pembayaran`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tampil_pembayaran`  AS SELECT `pb`.`id_pembayaran` AS `id_pembayaran`, `ps`.`id_pesanan` AS `id_pesanan`, `pb`.`tgl_dibayar` AS `tgl_dibayar`, `pb`.`bukti_pembayaran` AS `bukti_pembayaran`, `ps`.`tgl_pesanan` AS `tgl_pesanan`, `ps`.`total_harga_pesanan` AS `total_harga_pesanan`, `bb`.`nama_bank` AS `nama_bank`, `usr`.`nama` AS `nama`, `bb`.`no_rekening` AS `no_rekening` FROM (((`tb_pembayaran` `pb` join `tb_pesanan` `ps` on(`pb`.`id_pesanan` = `ps`.`id_pesanan`)) join `tb_bank_bayar` `bb` on(`bb`.`id_bank` = `ps`.`id_bank`)) join `tb_users` `usr` on(`usr`.`id_user` = `ps`.`id_users`))  ;

-- --------------------------------------------------------

--
-- Struktur untuk view `tampil_pesanan`
--
DROP TABLE IF EXISTS `tampil_pesanan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tampil_pesanan`  AS SELECT `ps`.`id_pesanan` AS `id_pesanan`, `ps`.`id_users` AS `id_users`, `ps`.`id_bank` AS `id_bank`, `ps`.`tgl_pesanan` AS `tgl_pesanan`, `ps`.`total_harga_pesanan` AS `total_harga_pesanan`, `ps`.`status` AS `status`, `bb`.`nama_bank` AS `nama_bank`, `bb`.`no_rekening` AS `no_rekening`, `u`.`nama` AS `nama`, `u`.`alamat` AS `alamat`, `u`.`no_telp` AS `no_telp` FROM ((`tb_pesanan` `ps` join `tb_bank_bayar` `bb` on(`bb`.`id_bank` = `ps`.`id_bank`)) join `tb_users` `u` on(`u`.`id_user` = `ps`.`id_users`))  ;

-- --------------------------------------------------------

--
-- Struktur untuk view `tampil_produk`
--
DROP TABLE IF EXISTS `tampil_produk`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tampil_produk`  AS SELECT `tb_produk`.`id_produk` AS `id_produk`, `tb_produk`.`id_suplier` AS `id_suplier`, `tb_produk`.`nama_produk` AS `nama_produk`, `tb_produk`.`merek` AS `merek`, `tb_produk`.`kategori` AS `kategori`, `tb_produk`.`harga` AS `harga`, `tb_produk`.`total_stok` AS `total_stok`, `tb_produk`.`warna` AS `warna`, `tb_produk`.`deskripsi` AS `deskripsi`, `tb_produk`.`gambar` AS `gambar` FROM `tb_produk` WHERE `tb_produk`.`total_stok` > 00  ;

-- --------------------------------------------------------

--
-- Struktur untuk view `tampil_produk_terbaru`
--
DROP TABLE IF EXISTS `tampil_produk_terbaru`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tampil_produk_terbaru`  AS SELECT `tb_produk`.`id_produk` AS `id_produk`, `tb_produk`.`nama_produk` AS `nama_produk`, `tb_produk`.`gambar` AS `gambar`, `tb_produk`.`harga` AS `harga`, `tb_produk`.`deskripsi` AS `deskripsi` FROM `tb_produk` WHERE `tb_produk`.`total_stok` > 0 LIMIT 0, 44  ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `tb_bank_bayar`
--
ALTER TABLE `tb_bank_bayar`
  ADD PRIMARY KEY (`id_bank`);

--
-- Indeks untuk tabel `tb_detail_pesanan`
--
ALTER TABLE `tb_detail_pesanan`
  ADD PRIMARY KEY (`id_detail_pesanan`),
  ADD KEY `tb_detail_pesanan_ibfk_1` (`id_pesanan`),
  ADD KEY `tb_detail_pesanan_ibfk_2` (`id_produk`);

--
-- Indeks untuk tabel `tb_detail_produk`
--
ALTER TABLE `tb_detail_produk`
  ADD PRIMARY KEY (`id_produk`,`ukuran`),
  ADD KEY `id_produk` (`id_produk`);

--
-- Indeks untuk tabel `tb_keranjang`
--
ALTER TABLE `tb_keranjang`
  ADD PRIMARY KEY (`id_keranjang`),
  ADD KEY `tb_keranjang_ibfk_1` (`id_produk`),
  ADD KEY `tb_keranjang_ibfk_2` (`id_user`);

--
-- Indeks untuk tabel `tb_pembayaran`
--
ALTER TABLE `tb_pembayaran`
  ADD PRIMARY KEY (`id_pembayaran`),
  ADD KEY `id_pesanan` (`id_pesanan`);

--
-- Indeks untuk tabel `tb_pesanan`
--
ALTER TABLE `tb_pesanan`
  ADD PRIMARY KEY (`id_pesanan`),
  ADD KEY `tb_pesanan_ibfk_1` (`id_users`),
  ADD KEY `tb_pesanan_ibfk_2` (`id_bank`);

--
-- Indeks untuk tabel `tb_produk`
--
ALTER TABLE `tb_produk`
  ADD PRIMARY KEY (`id_produk`),
  ADD KEY `tb_produk_ibfk_1` (`id_suplier`);

--
-- Indeks untuk tabel `tb_suplier`
--
ALTER TABLE `tb_suplier`
  ADD PRIMARY KEY (`id_suplier`);

--
-- Indeks untuk tabel `tb_users`
--
ALTER TABLE `tb_users`
  ADD PRIMARY KEY (`id_user`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `tb_bank_bayar`
--
ALTER TABLE `tb_bank_bayar`
  MODIFY `id_bank` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `tb_detail_pesanan`
--
ALTER TABLE `tb_detail_pesanan`
  MODIFY `id_detail_pesanan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=73;

--
-- AUTO_INCREMENT untuk tabel `tb_keranjang`
--
ALTER TABLE `tb_keranjang`
  MODIFY `id_keranjang` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT untuk tabel `tb_pembayaran`
--
ALTER TABLE `tb_pembayaran`
  MODIFY `id_pembayaran` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `tb_detail_pesanan`
--
ALTER TABLE `tb_detail_pesanan`
  ADD CONSTRAINT `tb_detail_pesanan_ibfk_1` FOREIGN KEY (`id_pesanan`) REFERENCES `tb_pesanan` (`id_pesanan`) ON DELETE CASCADE,
  ADD CONSTRAINT `tb_detail_pesanan_ibfk_2` FOREIGN KEY (`id_produk`) REFERENCES `tb_produk` (`id_produk`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `tb_detail_produk`
--
ALTER TABLE `tb_detail_produk`
  ADD CONSTRAINT `tb_detail_produk_ibfk_1` FOREIGN KEY (`id_produk`) REFERENCES `tb_produk` (`id_produk`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `tb_keranjang`
--
ALTER TABLE `tb_keranjang`
  ADD CONSTRAINT `tb_keranjang_ibfk_1` FOREIGN KEY (`id_produk`) REFERENCES `tb_produk` (`id_produk`) ON DELETE CASCADE,
  ADD CONSTRAINT `tb_keranjang_ibfk_2` FOREIGN KEY (`id_user`) REFERENCES `tb_users` (`id_user`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `tb_pembayaran`
--
ALTER TABLE `tb_pembayaran`
  ADD CONSTRAINT `tb_pembayaran_ibfk_1` FOREIGN KEY (`id_pesanan`) REFERENCES `tb_pesanan` (`id_pesanan`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `tb_pesanan`
--
ALTER TABLE `tb_pesanan`
  ADD CONSTRAINT `tb_pesanan_ibfk_1` FOREIGN KEY (`id_users`) REFERENCES `tb_users` (`id_user`) ON DELETE CASCADE,
  ADD CONSTRAINT `tb_pesanan_ibfk_2` FOREIGN KEY (`id_bank`) REFERENCES `tb_bank_bayar` (`id_bank`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `tb_produk`
--
ALTER TABLE `tb_produk`
  ADD CONSTRAINT `tb_produk_ibfk_1` FOREIGN KEY (`id_suplier`) REFERENCES `tb_suplier` (`id_suplier`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
