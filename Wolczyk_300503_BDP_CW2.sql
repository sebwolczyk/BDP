--CREATE DATABASE BDP_CW2;

CREATE EXTENSION postgis;

CREATE TABLE budynki(
	id INT NOT NULL PRIMARY KEY,
	geometria GEOMETRY,
	nazwa VARCHAR(30));

CREATE TABLE drogi(
	id INT NOT NULL PRIMARY KEY,
	geometria GEOMETRY,
	nazwa VARCHAR(30));

CREATE TABLE punkty_informacyjne(
	id INT NOT NULL PRIMARY KEY,
	geometria GEOMETRY,
	nazwa VARCHAR(30));

INSERT INTO budynki VALUES(1,ST_GeomFromText('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))',0),'BuildingA');
INSERT INTO budynki VALUES(2,ST_GeomFromText('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))',0),'BuildingB');
INSERT INTO budynki VALUES(3,ST_GeomFromText('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))',0),'BuildingC');
INSERT INTO budynki VALUES(4,ST_GeomFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))',0),'BuildingD');
INSERT INTO budynki VALUES(6,ST_GeomFromText('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))',0),'BuildingF');

INSERT INTO drogi VALUES(1,ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)',0),'RoadX');
INSERT INTO drogi VALUES(2,ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)',0),'RoadY');

INSERT INTO punkty_informacyjne VALUES(1,ST_GeomFromText('POINT(1 3.5)',0),'G');
INSERT INTO punkty_informacyjne VALUES(2,ST_GeomFromText('POINT(5.5 1.5)',0),'H');
INSERT INTO punkty_informacyjne VALUES(3,ST_GeomFromText('POINT(9.5 6)',0),'I');
INSERT INTO punkty_informacyjne VALUES(4,ST_GeomFromText('POINT(6.5 6)',0),'J');
INSERT INTO punkty_informacyjne VALUES(5,ST_GeomFromText('POINT(6 9.5)',0),'K');


--calkowita dlugosc drog
SELECT SUM(ST_Length(geometria)) AS calkowita_dlugosc_drog FROM drogi;

--geometria(WKT), pole oraz obwod BuildingA
SELECT ST_AsText(geometria) AS geometria, ST_Area(geometria) AS pole_powierzchni, ST_Perimeter(geometria) AS obwod FROM budynki
WHERE budynki.nazwa = 'BuildingA';

--nazwy i pola budynkow alfabetycznie
SELECT nazwa, ST_Area(Geometria) as pole_powierzchni FROM budynki
ORDER BY nazwa ASC;

--nazwy i obwody 2 budynków o najwiekszej powierzchni
SELECT nazwa, ST_Perimeter(Geometria) as obwod FROM budynki
WHERE id IN (SELECT id FROM budynki ORDER BY ST_Area(Geometria) DESC LIMIT 2);

--najkrotsza odleglosc miedzy BuildingC a G
SELECT ST_Distance(
	(SELECT geometria FROM budynki WHERE nazwa = 'BuildingC'),
	(SELECT geometria FROM punkty_informacyjne WHERE nazwa = 'G'))
	AS najkrotsza_odleglosc_Building_C_Punkt_G;
	
--pole czesci BuildingC, ktora znajduje sie w odleglosci > 0.5 od BuildingB
SELECT ST_Area(
		(SELECT geometria  AS BuildingC FROM budynki WHERE nazwa = 'BuildingC')
	) - ST_Area(
			(SELECT ST_Intersection(
				ST_Buffer((SELECT geometria FROM budynki WHERE nazwa = 'BuildingB'),0.5),
				(SELECT geometria FROM budynki WHERE nazwa = 'BuildingC')
				))) AS pole;

--budynki, ktorych centroid jest powyzj RoadX
SELECT budynki.nazwa, ST_AsText(ST_CENTROID(budynki.geometria)) AS centroid, ST_AsText(budynki.geometria) AS geometria FROM budynki
WHERE (SELECT ST_Y(ST_CENTROID(budynki.geometria))) > 4.5;

--pole czesci NIEwspolnych miedzy BuildingC a poligonem
SELECT (
	ST_Area(
	ST_Difference(geometria,ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))',0)))
	+
	ST_Area(
	ST_Difference(ST_GeomFromText('Polygon((4 7, 6 7, 6 8, 4 8, 4 7))',0),geometria))
) AS pole FROM budynki WHERE nazwa = 'BuildingC';
