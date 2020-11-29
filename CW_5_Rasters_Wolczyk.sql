CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;
--cd "E:\Program Files\PostgreSQL\12\bin"
--Ladowanie danych-----------------------------------------------------------------------------------------------------
--przyklad 1
raster2pgsql.exe -s 3763 -N -32767 -t 100x100 -I -C -M -d "E:\Studia\Bazy_danych_przestrzennych\postgis_raster\rasters\srtm_1arc_v3.tif" rasters.dem > E:\Studia\Bazy_danych_przestrzennych\postgis_raster\dem.sql
--przyklad 2
raster2pgsql.exe -s 3763 -N -32767 -t 100x100 -I -C -M -d "E:\Studia\Bazy_danych_przestrzennych\postgis_raster\rasters\srtm_1arc_v3.tif" rasters.dem | psql -d postgis_raster -h localhost -U postgres -p 5432
--przyklad 3
raster2pgsql.exe -s 3763 -N -32767 -t 128x128 -I -C -M -d "E:\Studia\Bazy_danych_przestrzennych\postgis_raster\rasters\Landsat8_L1TP_RGBN.TIF" rasters.landsat8 | psql -d postgis_raster -h localhost -U postgres -p 5432

--Tworzenie rastrow z isniejacych rastrow i interakcja z wektorami-----------------------------------------------------
--przyklad 1 ST_INTERSECTS
CREATE TABLE wolczyk.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

--dodanie serial primary key
ALTER TABLE wolczyk.intersects
ADD COLUMN rid SERIAL PRIMARY KEY;

--utworzenie indeksu przestrzennego
CREATE INDEX idx_intersects_rast_gist ON wolczyk.intersects
USING gist (ST_ConvexHull(rast));

--dodanie raster constraints
-- schema::name table_name::name raster_column::name
SELECT AddRasterConstraints('wolczyk'::name,
'intersects'::name,'rast'::name);

--przyklad 2 ST_CLIPS
CREATE TABLE wolczyk.clip AS
SELECT ST_Clip(a.rast, b.geom, true), b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

--przyklad 3 ST_UNION
CREATE TABLE wolczyk.union AS
SELECT ST_Union(ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b 
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);

--Tworzenie rastrow z wektorow------------------------------------------------------------------------------------------
--Przyklad 1 ST_AsRaster
CREATE TABLE wolczyk.porto_parishes AS
WITH r AS (
		SELECT rast FROM rasters.dem
		LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--Przyklad 2 ST_Union
DROP TABLE wolczyk.porto_parishes; --> drop table porto_parishes first
CREATE TABLE wolczyk.porto_parishes AS
WITH r AS (
		SELECT rast FROM rasters.dem
		LIMIT 1
)
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--Przyklad 3 ST_Tile
DROP TABLE wolczyk.porto_parishes; --> drop table porto_parishes first
CREATE TABLE wolczyk.porto_parishes AS
WITH r AS (
		SELECT rast FROM rasters.dem
		LIMIT 1 )
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-
32767)),128,128,true,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--Konwertowanie rastrow na wektory-----------------------------------------------------------------------------------------
--Przyklad 1 ST_Intersection
create table wolczyk.intersection as
SELECT
a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)
).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--Przyklad 2 ST_DumpAsPolygons
CREATE TABLE wolczyk.dumppolygons AS
SELECT
a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--Analiza rastrow------------------------------------------------------------------------------------------------------------
--Przyklad 1 ST_Band
CREATE TABLE wolczyk.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;

--Przyklad 2 ST_Clip
CREATE TABLE wolczyk.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--Przyklad 3 ST_Slope
CREATE TABLE wolczyk.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM wolczyk.paranhos_dem AS a;

--Przyklad 4 ST_Reclass
CREATE TABLE wolczyk.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3',
'32BF',0)
FROM wolczyk.paranhos_slope AS a;

--Przyklad 5 ST_SummaryStats
SELECT st_summarystats(a.rast) AS stats
FROM wolczyk.paranhos_dem AS a;

--Przyklad 6 ST_SummaryStats oraz ST_Union
SELECT st_summarystats(ST_Union(a.rast))
FROM wolczyk.paranhos_dem AS a;

--Przyklad 7 ST_SummaryStats z lepsza kontrola zlozonego typu danych
WITH t AS (
	SELECT st_summarystats(ST_Union(a.rast)) AS stats
	FROM wolczyk.paranhos_dem AS a
)
SELECT (stats).min,(stats).max,(stats).mean FROM t;

--Przyklad 8 ST_SummaryStats w polaczeniu z GROPU BY
WITH t AS (
	SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast,
b.geom,true))) AS stats
	FROM rasters.dem AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
	group by b.parish
)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;

--Przyklad 9 ST_Value
SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM
rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;

--Przyklad 10 ST_TPI
create table wolczyk.tpi30 as
select ST_TPI(a.rast,1) as rast
from rasters.dem a;

CREATE INDEX idx_tpi30_rast_gist ON wolczyk.tpi30
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('wolczyk'::name,
'tpi30'::name,'rast'::name);

--skrocenie czasu zapytania
CREATE TABLE wolczyk.tpi30_porto as
SELECT ST_TPI(a.rast,1) as rast
FROM rasters.dem a, vectors.porto_parishes AS b WHERE  ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto'

CREATE INDEX idx_tpi30_porto_rast_gist ON wolczyk.tpi30_porto
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('wolczyk'::name, 'tpi30_porto'::name,'rast'::name);

--Algebra map-------------------------------------------------------------------------------------------------------------------
--Przyklad 1 Wyrazenie Algebry Map
CREATE TABLE wolczyk.porto_ndvi AS
WITH r AS (
		SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
		FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
		WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
		r.rid,ST_MapAlgebra(
				r.rast, 1,
				r.rast, 4,
				'([rast2.val] - [rast1.val]) / ([rast2.val] +
[rast1.val])::float','32BF'
		) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi_rast_gist ON wolczyk.porto_ndvi
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('wolczyk'::name,
'porto_ndvi'::name,'rast'::name);

--Przyklad 2 Funkcja zwrotna
create or replace function wolczyk.ndvi(
		value double precision [] [] [],
		pos integer [][],
		VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
		--RAISE NOTICE 'Pixel Value: %', value [1][1][1];-->For debug purposes
		RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value
[1][1][1]); --> NDVI calculation!
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;

CREATE TABLE wolczyk.porto_ndvi2 AS
WITH r AS (
		SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
		FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
		WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
		r.rid,ST_MapAlgebra(
				r.rast, ARRAY[1,4],
				'wolczyk.ndvi(double precision[],
integer[],text[])'::regprocedure, --> This is the function!
				'32BF'::text
	) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi2_rast_gist ON wolczyk.porto_ndvi2
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('wolczyk'::name,
'porto_ndvi2'::name,'rast'::name);

--eksport danych-----------------------------------------------------------------------------------------------------------
--przyklad 1 ST_AsTiff
SELECT ST_AsTiff(ST_Union(rast))
FROM wolczyk.porto_ndvi;

--Przyklad 2 ST_AsGDALRaster
SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
FROM wolczyk.porto_ndvi;
--wyswietlenie listy formatow oblusigwanych przez bibioleteke GDAL
SELECT ST_GDALDrivers();

--Przyklad 3 Zapisywanie danych na dysku za pomoca duzego obiektu
CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
 	ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
	 ) AS loid
FROM wolczyk.porto_ndvi;
----------------------------------------------
SELECT lo_export(loid, 'E:\Studia\Bazy_danych_przestrzennych\postgis_raster\myraster.tiff') --> Save the file in a place
--where the user postgres have access. In windows a flash drive usualy works
--fine.
 FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid)
 FROM tmp_out; --> Delete the large object.