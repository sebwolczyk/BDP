--CREATE DATABASE BDP_CW4;

CREATE EXTENSION postgis;

--utworzenie tabeli
CREATE TABLE obiekty(
id INT NOT NULL PRIMARY KEY,
nazwa VARCHAR(50),
geometria GEOMETRY);

-------------------------------------------------------------------------------------------------------------
--obiekt1
INSERT INTO obiekty VALUES
(1,'obiekt1',ST_GeomFromText('MULTICURVE((0 1, 1 1),CIRCULARSTRING(1 1, 2 0, 3 1),CIRCULARSTRING(3 1, 4 2, 5 1),(5 1, 6 1))',0));
--obiekty posiadajace geometrie curve lub circular nie wyswietlaja sie w geometry viewer
--narzucenie na nich malego buffera pozwala zobaczyc ich ksztalt
SELECT ST_BUFFER(geometria, 0.001) FROM obiekty
WHERE id =1;

--obiekt2
INSERT INTO obiekty VALUES
(2,'obiekt2',ST_GeomFromText('CURVEPOLYGON(COMPOUNDCURVE((10 2, 10 6, 14 6),CIRCULARSTRING(14 6, 16 4, 14 2, 12 0, 10 2)),CIRCULARSTRING(11 2, 13 2, 11 2))',0));
SELECT ST_BUFFER(geometria, 0.001) FROM obiekty
WHERE id =2;

--obiekt3
INSERT INTO obiekty VALUES
(3,'obiekt3',ST_GeomFromText('POLYGON((7 15, 10 17, 12 13, 7 15))',0));

--obiekt4
INSERT INTO obiekty VALUES
(4,'obiekt4',ST_GeomFromText('LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)',0))

--obiekt5
INSERT INTO obiekty VALUES
(5,'obiekt5',ST_GeomFromText('MULTIPOINT Z((30 30 59),(38 32 234))',0))

--obiekt6
INSERT INTO obiekty VALUES
(6,'obiekt6',ST_GeomFromText('GEOMETRYCOLLECTION(LINESTRING(1 1, 3 2),POINT(4 2))',0))
-------------------------------------------------------------------------------------------------------------

--zapytanie 1
SELECT ST_Area(ST_Buffer(ST_ShortestLine((SELECT geometria FROM obiekty WHERE id = 3),(SELECT geometria FROM obiekty WHERE id = 4)),5)) AS pole

--zapytanie 2
--Obekt 4 nie jest obiektem zamknietym, wiec trzeba dodac jedna linie celem zamkniecia obiektu.
--Wtedy mozna utworzyc poligon
UPDATE obiekty
SET geometria = ST_GeomFromText('Polygon((20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5, 20 20))')
WHERE id = 4;

--zapytanie 3
--zapytanie select pozwala latwo skopiowac geometrie poligonow
SELECT ST_AsText(geometria) FROM obiekty WHERE id = 3 OR id = 4;
INSERT INTO obiekty VALUES
(7,'obiekt7',ST_GeomFromText('MULTIPOLYGON(((7 15,10 17,12 13,7 15)),((20 20,25 25,27 24,25 22,26 21,22 19,20.5 19.5,20 20)))',0))

--zapytanie 4
--SUMA POL POWIERZCHNI OBIEKTOW BEZ LUKOW
SELECT SUM(ST_Area(ST_Buffer(o.geometria,5))) AS Pole FROM obiekty o
WHERE ST_HasArc(o.geometria) = false;
--sprawdzenie czy poprawne obiekty sa wybrane po podaniu warunkow zapytania
SELECT id, ST_Area(ST_Buffer(o.geometria,5)) AS Pole FROM obiekty o
WHERE ST_HasArc(o.geometria) = false;