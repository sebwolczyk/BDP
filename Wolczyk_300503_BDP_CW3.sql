--CREATE DATABASE BDP_CW3;

CREATE EXTENSION postgis;

--liczba budynkow w odleglosci mniejszej niz 100 000m od glownych rzek
--wypisanie liczby budynkow
SELECT COUNT(DISTINCT p.gid) FROM popp p, majrivers mr 
WHERE ST_DWithin(mr.geom, p.geom, 100000)
AND p.f_codedesc = 'Building';

--przypisanie budynkow do nowej tabeli
SELECT DISTINCT p.gid, p.cat, p.f_codedesc, p.f_code, p.type, p.geom INTO tableB FROM popp p, majrivers mr
WHERE ST_DWithin(mr.geom, p.geom, 100000)
AND p.f_codedesc = 'Building'
ORDER BY p.gid;

SELECT * FROM tableB

--tablera airportsNew oraz import
CREATE TABLE airportsNew
  AS (SELECT a.name, a.geom, a.elev FROM airports a); 

--najbardziej na wschod
SELECT a.name AS nazwa_lotniska_najbardziej_na_wschod, ST_AsText(a.geom) AS wspolrzedne FROM airportsNew a
ORDER BY ST_X(a.geom) DESC LIMIT 1;

--najbardziej na zachod
SELECT a.name AS nazwa_lotniska_najbardziej_na_zachod, ST_AsText(a.geom) AS wspolrzedne FROM airportsNew a
ORDER BY ST_X(a.geom) ASC LIMIT 1;

--dodanie nowego obiektu do tabeli, ktory jest w punkcie srodkowym drogi z lotnisk najbardziej na wschod i zachod
INSERT INTO airportsNew
VALUES('airportB',(SELECT ST_Centroid(
		(SELECT DISTINCT ST_ShortestLine((SELECT geom FROM airportsNew WHERE name='ANNETTE ISLAND'),(SELECT geom FROM airportsNew WHERE name='ATKA'))
		FROM airportsNew))),34.000);
--sprawdzenie czy dziala(w podgladzie geometrii widac, ze dodany punkt jest idealnie po srodku drogi miedzy lotniskami)	
SELECT * FROM airportsNew WHERE name='airportB' OR name= 'ANNETTE ISLAND' OR name= 'ATKA';

--pole powierzchni obszaru oddalonego mniej niz 1000 od najkrotszej linii laczacej jezioro i lotnisko
SELECT ST_AREA(ST_BUFFER(ST_ShortestLine(a.geom,l.geom),1000)) AS Pole_powierzchni FROM airportsNew a, lakes l
WHERE a.name = 'AMBLER'
AND l.names = 'Iliamna Lake'

--Sumaryczne pole powierzchni poligonow poszczegolnych typow drzew w tundrze i na bagnach
SELECT SUM(DISTINCT tr.area_km2) AS Pole, vegdesc FROM trees tr, swamp s, tundra tu
WHERE ST_Within(tr.geom, s.geom)
OR ST_Within(tr.geom, tu.geom)
GROUP BY vegdesc;
