--1
CREATE DATABASE s300503;

--2
CREATE SCHEMA firma;

--3
CREATE ROLE ksiegowosc;
GRANT CONNECT ON DATABASE s300503 TO ksiegowosc;
GRANT USAGE ON SCHEMA firma TO ksiegowosc;
GRANT SELECT ON ALL TABLES IN SCHEMA firma TO ksiegowosc;

--4
CREATE TABLE firma.pracownicy(
	id_pracownika VARCHAR(5) NOT NULL,
	imie VARCHAR(30) NOT NULL,
	nazwisko VARCHAR(50) NOT NULL,
	adres VARCHAR(150),
	telefon VARCHAR(15));

ALTER TABLE firma.pracownicy ADD PRIMARY KEY (id_pracownika);

COMMENT ON TABLE firma.pracownicy
	IS 'Baza wszystkich pracownikow firmy.';
	
COMMENT ON COLUMN firma.pracownicy.id_pracownika
	IS 'M-Mezczyzna; K-Kobieta; plus unikalna liczba.';
	
CREATE TABLE firma.godziny(
	id_godziny SMALLINT NOT NULL,
	data DATE,
	liczba_godzin INT,
	id_pracownika VARCHAR(5));
	
ALTER TABLE firma.godziny ADD PRIMARY KEY (id_godziny);
	
COMMENT ON TABLE firma.godziny
	IS 'Godziny przepracowane przez danego pracownika w danym miesiacu.';
	
COMMENT ON COLUMN firma.godziny.data
	IS 'Liczba godzin przepracowanych przez pracownika rozliczania jest za miesiac, kazdego ostatniego dnia miesiaca.';

CREATE TABLE firma.pensja_stanowisko(
	id_pensji SMALLINT NOT NULL,
	stanowisko VARCHAR(50),
	kwota MONEY);
	
ALTER TABLE firma.pensja_stanowisko ADD PRIMARY KEY (id_pensji);

COMMENT ON TABLE firma.pensja_stanowisko
	IS 'Baza pensji w zaleznosci od stanowiska.';
	
CREATE TABLE firma.premia(
	id_premii VARCHAR(5) NOT NULL,
	rodzaj VARCHAR(50),
	kwota MONEY);

ALTER TABLE firma.premia ADD PRIMARY KEY (id_premii);

COMMENT ON TABLE firma.premia
	IS 'Baza wszystkich premii, ktore moze przyznac firma celem podwyzszenia wynagrodzenia.';
	
COMMENT ON COLUMN firma.premia.id_premii
	IS 'Unikalny skrot literowy od nazwy rodzaju premii.';
	
COMMENT ON COLUMN firma.premia.rodzaj
	IS 'Rodzaj opisuje za co przyznawana jest premia.';
	
CREATE TABLE firma.wynagrodzenie(
	id_wynagrodzenia INT NOT NULL,
	data DATE,
	id_pracownika VARCHAR(5),
	id_godziny SMALLINT,
	id_pensji SMALLINT,
	id_premii VARCHAR(5));
	
ALTER TABLE firma.wynagrodzenie ADD PRIMARY KEY (id_wynagrodzenia);

COMMENT ON TABLE firma.wynagrodzenie
	IS 'Baza wszystkich comiesiecznych wynagrodzen.';
	
COMMENT ON COLUMN firma.wynagrodzenie.data
	IS 'Data wyplaty wynagrodzenia,';
	
ALTER TABLE firma.godziny ADD FOREIGN KEY (id_pracownika) REFERENCES firma.pracownicy(id_pracownika);
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY (id_pracownika) REFERENCES firma.pracownicy(id_pracownika);
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY (id_godziny) REFERENCES firma.godziny(id_godziny);
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY (id_pensji) REFERENCES firma.pensja_stanowisko(id_pensji);
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY (id_premii) REFERENCES firma.premia(id_premii);

--5
--a.
ALTER TABLE firma.godziny ADD COLUMN nr_miesiaca INT;
ALTER TABLE firma.godziny ADD COLUMN nr_tygodnia INT;
--b.
ALTER TABLE firma.wynagrodzenie ALTER COLUMN data SET DATA TYPE VARCHAR(50);

INSERT INTO firma.pracownicy VALUES('M001','Jan','Nowak','ul. Rynek 1, 31-435 Kraków','+48 667006123');
INSERT INTO firma.pracownicy VALUES('K101','Katarzyna','Noga','ul. Gołębia 32a, 31-435 Kraków','+48 652489633');
INSERT INTO firma.pracownicy VALUES('K102','Sandra','Czarnecka','ul. Rysia 112, 30-243 Tarnów','+48 660987432');
INSERT INTO firma.pracownicy VALUES('M003','Janusz','Kręgiel','ul. Słona 42, 31-435 Kraków','+48 696750998');
INSERT INTO firma.pracownicy VALUES('K106','Izabela','Kręgiel','ul. Słona 42, 31-435 Kraków','+48 696789321');
INSERT INTO firma.pracownicy VALUES('M009','Mirosław','Gołąb','ul. Ptasia 119, 04-242 Lublin','+48 535969706');
INSERT INTO firma.pracownicy VALUES('K015','Alicja','Kot','ul. Piękna 4, 31-435 Kraków','+48 535976502');
INSERT INTO firma.pracownicy VALUES('M021','Tomasz','Łoś','ul. Rybia 55a, 31-435 Kraków','+48 612131415');
INSERT INTO firma.pracownicy VALUES('K040','Łucja','Tygrys','ul. Majestatyczna 9, 41-200 Katowice','+48 694523053');
INSERT INTO firma.pracownicy VALUES('M0154','Aleksander','Wolski','ul. Jasna, 33-425 Biały Dwór','+48 698887624');

INSERT INTO firma.godziny VALUES(1,'2021-08-31',240,'M001',(SELECT date_part('month',TIMESTAMP '2021-08-31')),(SELECT date_part('week',TIMESTAMP '2021-08-31')));
INSERT INTO firma.godziny VALUES(2,'2021-08-31',240,'K101',(SELECT date_part('month',TIMESTAMP '2021-08-31')),(SELECT date_part('week',TIMESTAMP '2021-08-31')));
INSERT INTO firma.godziny VALUES(3,'2021-08-31',160,'K102',(SELECT date_part('month',TIMESTAMP '2021-08-31')),(SELECT date_part('week',TIMESTAMP '2021-08-31')));
INSERT INTO firma.godziny VALUES(4,'2021-09-30',160,'M003',(SELECT date_part('month',TIMESTAMP '2021-09-30')),(SELECT date_part('week',TIMESTAMP '2021-09-30')));
INSERT INTO firma.godziny VALUES(5,'2021-09-30',190,'K106',(SELECT date_part('month',TIMESTAMP '2021-09-30')),(SELECT date_part('week',TIMESTAMP '2021-09-30')));
INSERT INTO firma.godziny VALUES(6,'2021-09-30',160,'M009',(SELECT date_part('month',TIMESTAMP '2021-09-30')),(SELECT date_part('week',TIMESTAMP '2021-09-30')));
INSERT INTO firma.godziny VALUES(7,'2021-09-30',140,'K015',(SELECT date_part('month',TIMESTAMP '2021-09-30')),(SELECT date_part('week',TIMESTAMP '2021-09-30')));
INSERT INTO firma.godziny VALUES(8,'2021-09-30',80,'M021',(SELECT date_part('month',TIMESTAMP '2021-09-30')),(SELECT date_part('week',TIMESTAMP '2021-09-30')));
INSERT INTO firma.godziny VALUES(9,'2021-09-30',160,'K040',(SELECT date_part('month',TIMESTAMP '2021-09-30')),(SELECT date_part('week',TIMESTAMP '2021-09-30')));
INSERT INTO firma.godziny VALUES(10,'2021-09-30',210,'M0154',(SELECT date_part('month',TIMESTAMP '2021-09-30')),(SELECT date_part('week',TIMESTAMP '2021-09-30')));

INSERT INTO firma.pensja_stanowisko VALUES(100,'Kierownik',10000);
INSERT INTO firma.pensja_stanowisko VALUES(101,'Software Developer',7500);
INSERT INTO firma.pensja_stanowisko VALUES(102,'Junior Developer',6000);
INSERT INTO firma.pensja_stanowisko VALUES(103,'Server Admin',3000);
INSERT INTO firma.pensja_stanowisko VALUES(104,'Graphic Designer',4500);
INSERT INTO firma.pensja_stanowisko VALUES(105,'Public Relations Manager',3500);
INSERT INTO firma.pensja_stanowisko VALUES(106,'Księgowość',2650);
INSERT INTO firma.pensja_stanowisko VALUES(107,'Sekretarka',1800);
INSERT INTO firma.pensja_stanowisko VALUES(108,'Ochroniarz',900);
INSERT INTO firma.pensja_stanowisko VALUES(109,'Sprzątaczka',750);


INSERT INTO firma.premia VALUES('NAD','Nadgodziny',1000);
INSERT INTO firma.premia VALUES('WKND','Praca w weekendy',500);
INSERT INTO firma.premia VALUES('HLDAY','Praca w święta',250);
INSERT INTO firma.premia VALUES('NIGHT','Praca w godzinach nocnych',500);
INSERT INTO firma.premia VALUES('MONTH','Pracownik miesiąca',500);
INSERT INTO firma.premia VALUES('EVENT','Organizacja eventu',300);
INSERT INTO firma.premia VALUES('ONTIM','Punktualność',100);
INSERT INTO firma.premia VALUES('UPGR','Usprawnienie działania firmy',3000);
INSERT INTO firma.premia VALUES('IDEA','Pomysłodawctwo',600);
INSERT INTO firma.premia VALUES('BHVR','Sprawowanie',200);
INSERT INTO firma.premia VALUES('BRAK','Brak premii',0);

INSERT INTO firma.wynagrodzenie VALUES(1000,'2021-09-10','M001',1,100,'BRAK');
INSERT INTO firma.wynagrodzenie VALUES(1001,'2021-09-10','K101',2,100,'BRAK');
INSERT INTO firma.wynagrodzenie VALUES(1002,'2021-09-10','K102',3,105,'EVENT');
INSERT INTO firma.wynagrodzenie VALUES(1003,'2021-10-10','M003',4,101,'MONTH');
INSERT INTO firma.wynagrodzenie VALUES(1004,'2021-10-10','K106',5,101,'HLDAY');
INSERT INTO firma.wynagrodzenie VALUES(1005,'2021-10-10','M009',6,103,'BRAK');
INSERT INTO firma.wynagrodzenie VALUES(1006,'2021-10-10','K015',7,106,'UPGR');
INSERT INTO firma.wynagrodzenie VALUES(1007,'2021-10-10','M021',8,107,'BRAK');
INSERT INTO firma.wynagrodzenie VALUES(1008,'2021-10-10','K040',9,108,'NIGHT');
INSERT INTO firma.wynagrodzenie VALUES(1009,'2021-10-10','M0154',10,109,'BHVR');

--6
--a
SELECT id_pracownika, nazwisko FROM firma.pracownicy;
--b
SELECT id_pracownika, kwota FROM firma.wynagrodzenie, firma.pensja_stanowisko 
WHERE firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji
AND kwota > '1000';
--c
SELECT id_pracownika, kwota, id_premii FROM firma.wynagrodzenie, firma.pensja_stanowisko 
WHERE firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji
AND firma.wynagrodzenie.id_premii = 'BRAK'
AND kwota > '2000';
--d
SELECT * FROM firma.pracownicy WHERE imie LIKE 'J%';
--e
SELECT * FROM firma.pracownicy
WHERE nazwisko LIKE '%n%' AND imie LIKE '%a';
--f
SELECT imie, nazwisko, liczba_godzin - 160 AS nadgodziny
FROM firma.pracownicy, firma.godziny
WHERE firma.pracownicy.id_pracownika = firma.godziny.id_pracownika
AND liczba_godzin > 160;
--g
SELECT imie, nazwisko, kwota
FROM firma.pracownicy, firma.pensja_stanowisko, firma.wynagrodzenie
WHERE firma.pensja_stanowisko.id_pensji = firma.wynagrodzenie.id_pensji
AND firma.pracownicy.id_pracownika = firma.wynagrodzenie.id_pracownika
AND '1500' <= kwota AND kwota <= '3000';
--h
SELECT imie, nazwisko, liczba_godzin -160 AS nadgodziny, id_premii
FROM firma.pracownicy, firma.godziny, firma.wynagrodzenie
WHERE firma.pracownicy.id_pracownika = firma.godziny.id_pracownika
AND firma.wynagrodzenie.id_godziny = firma.godziny.id_godziny
AND id_premii = 'BRAK'
AND liczba_godzin > 160;

--7
--a
SELECT pracownicy.id_pracownika, imie, nazwisko, kwota AS pensja FROM firma.pracownicy, firma.pensja_stanowisko, firma.wynagrodzenie
WHERE firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji
AND firma.wynagrodzenie.id_pracownika = firma.pracownicy.id_pracownika
ORDER BY kwota;
--b
SELECT pracownicy.id_pracownika, imie, nazwisko, pensja_stanowisko.kwota AS pensja, premia.kwota AS premia
FROM firma.pracownicy, firma.pensja_stanowisko, firma.premia, firma.wynagrodzenie
WHERE firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji
AND firma.wynagrodzenie.id_premii = firma.premia.id_premii
AND firma.wynagrodzenie.id_pracownika = firma.pracownicy.id_pracownika
ORDER BY pensja DESC, premia DESC;
--c
SELECT count(id_pracownika) AS ilość, stanowisko FROM firma.pensja_stanowisko, firma.wynagrodzenie
WHERE firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji
GROUP BY stanowisko;
--d
SELECT CAST(AVG(kwota::numeric) AS DECIMAL(10,2)) AS średnia, MIN(kwota::numeric) AS minimum,MAX(kwota::numeric) AS maksimum
FROM firma.pensja_stanowisko
WHERE firma.pensja_stanowisko.stanowisko = 'Kierownik';
--e
SELECT SUM(pensja_stanowisko.kwota::numeric) + SUM(premia.kwota::numeric) AS suma
FROM firma.wynagrodzenie, firma.pensja_stanowisko, firma.premia
WHERE firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji
AND firma.wynagrodzenie.id_premii = firma.premia.id_premii;
--f
SELECT stanowisko, SUM(pensja_stanowisko.kwota::numeric) + SUM(premia.kwota::numeric) AS suma
FROM firma.wynagrodzenie, firma.pensja_stanowisko, firma.premia
WHERE firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji
AND firma.wynagrodzenie.id_premii = firma.premia.id_premii
GROUP BY stanowisko
ORDER BY suma DESC;
--g
SELECT stanowisko, count(wynagrodzenie.id_premii) AS liczba_premii
FROM firma.wynagrodzenie, firma.pensja_stanowisko, firma.premia
WHERE firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji
AND firma.wynagrodzenie.id_premii = firma.premia.id_premii
AND wynagrodzenie.id_premii != 'BRAK'
GROUP BY stanowisko
ORDER BY liczba_premii DESC;
--h
DELETE FROM firma.pracownicy 
USING firma.pensja_stanowisko, firma.wynagrodzenie
WHERE firma.pracownicy.id_pracownika =  firma.wynagrodzenie.id_pracownika
AND firma.pensja.id_pensji = firma.wynagrodzenie.id_pensji
AND firma.pensja_stanowisko.kwota < '1200';
--nie da sie usunac pracownika z tabeli pracownicy jesli istnieja klucze obce w innych tabelach, ktore odwoluja sie do danego pracownika
--a istnieja dwa klucze obce- w tabeli godziny i wynagrodzenie
--nalezaloby najpierw usunac wpisy z tabel wynagrodzenie i godziny??

/*
DELETE FROM firma.wynagrodzenie
USING firma.pensja_stanowisko, firma.pracownicy
WHERE firma.pracownicy.id_pracownika =  firma.wynagrodzenie.id_pracownika
AND firma.pensja_stanowisko.id_pensji = firma.wynagrodzenie.id_pensji
AND firma.pensja_stanowisko.kwota < '1200';

DELETE FROM firma.godziny
USING firma.pensja_stanowisko, firma.pracownicy, firma.wynagrodzenie
WHERE firma.pensja_stanowisko.id_pensji = firma.wynagrodzenie.id_pensji
AND firma.pensja.kwota < '1200';
*/

--Usuwajac najpierw z tabeli wynagrodzenie nie ma potem juz odniesienia za bardzo na jakiej podstawie usuwac z tabeli godziny, a nastepnie pracownicy
--tabela wynagrodzenie wiaze ze soba pensje oraz pracownikow, po usunieciu rekordu wynagrodzenie nie wiemy juz jakie pensje otrzymywal dany pracownik
--mozemy co najwyzej usunac wynagrodzenia pracownikow z pensja <1200

--8
--a
--+48 juz istnialo w numerach telefonu stad uzycie substring celem dodania nawiasów w odpowiednich miejscach
UPDATE firma.pracownicy SET telefon = '(' || SUBSTRING(telefon,1,3) || ')' || SUBSTRING(telefon,5,9)
--b
ALTER TABLE firma.pracownicy ALTER COLUMN telefon TYPE VARCHAR(20);
UPDATE firma.pracownicy
SET telefon = SUBSTRING(telefon,1,5) || ' ' || SUBSTRING(telefon,6,3) || '-' || SUBSTRING(telefon,9,3) || '-' || SUBSTRING(telefon,12,3);
--c
SELECT id_pracownika, UPPER(imie) AS IMIE, UPPER(nazwisko) AS NAZWISKO, UPPER(adres) AS ADRES, telefon FROM firma.pracownicy
WHERE LENGTH(nazwisko) = (SELECT MAX(LENGTH(nazwisko)) FROM firma.pracownicy);
--d
SELECT (firma.pracownicy.*), MD5(kwota::VARCHAR(20)) AS pensja 
FROM firma.pracownicy, firma.wynagrodzenie, firma.pensja_stanowisko 
WHERE firma.pracownicy.id_pracownika = firma.wynagrodzenie.id_pracownika
AND firma.pensja_stanowisko.id_pensji = firma.wynagrodzenie.id_pensji;

--9
--Dodatkowe uzycie substring celem dodania kropek pomiedzy rokiem, miesiacem a dniem,
--poniewaz date jest w formacie (yyyy-mm-dd).
SELECT CONCAT('Pracownik ', firma.pracownicy.imie,' ', firma.pracownicy.nazwisko,
', w dniu ', SUBSTRING(firma.wynagrodzenie.data::VARCHAR(20),1,4), '.', 
SUBSTRING(firma.wynagrodzenie.data::VARCHAR(20),6,2), '.', SUBSTRING(firma.wynagrodzenie.data::VARCHAR(20),9,2),
' otrzymał pensję całkowitą na kwotę ', (firma.pensja_stanowisko.kwota + firma.premia.kwota),
', gdzie wynagrodzenie zasadnicze wynosiło: ', firma.pensja_stanowisko.kwota,
', premia: ', firma.premia.kwota,
', nadgodziny: ', CASE WHEN firma.wynagrodzenie.id_premii = 'NAD' THEN 1000 ELSE 0 END, ' zł' )
AS raport
FROM firma.wynagrodzenie, firma.pracownicy, firma.pensja_stanowisko, firma.premia, firma.godziny
WHERE firma.pracownicy.id_pracownika = firma.wynagrodzenie.id_pracownika
AND firma.pracownicy.id_pracownika = firma.godziny.id_pracownika
AND firma.wynagrodzenie.id_premii = firma.premia.id_premii 
AND firma.wynagrodzenie.id_pensji = firma.pensja_stanowisko.id_pensji;