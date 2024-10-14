-- Create table for station.csv
CREATE TABLE station (
  station_cd int DEFAULT NULL,
  station_g_cd int DEFAULT NULL,
  station_name varchar(150) DEFAULT NULL,
  line_cd int DEFAULT NULL,
  pref_cd int DEFAULT NULL,
  postcode int DEFAULT NULL,
  prefecture varchar(150) DEFAULT NULL,
  address_en varchar(255) DEFAULT NULL,
  lon decimal(10,6) DEFAULT NULL,
  lat decimal(10,6) DEFAULT NULL,
  open_ymd date DEFAULT NULL,
  close_ymd date DEFAULT NULL,
  e_status int DEFAULT NULL,
  e_sort int DEFAULT NULL,
  station_status varchar(20) DEFAULT NULL
) ;

-- Load station.csv into database
LOAD DATA LOCAL INFILE '.../station_updated_2.csv' 
INTO TABLE station
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
IGNORE 1 ROWS;


-- Finding total no. of unique stations in a prefecture
SELECT prefecture, COUNT(DISTINCT station_name) AS total_no_of_stations
FROM station
GROUP BY 1
ORDER BY 2 DESC;


-- Finding total no. of closed stations in a prefecture
SELECT count(DISTINCT CASE WHEN station_status = 'closed' THEN station_name END) AS total_closed_stations, prefecture
FROM station
GROUP BY 2
ORDER BY 1 DESC, 2;


-- Displaying total no. of stations and closed stations in a prefecture
SELECT station.prefecture, COUNT(DISTINCT station_name) AS total_no_of_station, 
	  total_closed_stations
FROM station 
	   JOIN (SELECT prefecture,
			 COUNT(DISTINCT CASE WHEN station_status = 'closed' THEN station_name END) AS total_closed_stations 
			 FROM station 
			 GROUP BY prefecture) AS a
		ON station.prefecture = a.prefecture
GROUP BY 1
ORDER BY 3 DESC;


-- FINDING THE PERCENTAGE OF CLOSED STATIONS 
SELECT prefecture, (SUM(closed) / SUM(total)) * 100 AS percentage_closed_stations
FROM ( 
	  SELECT prefecture, COUNT(DISTINCT station_name) as closed, 0 as total
      FROM station
      WHERE station_status = 'CLOSED'
      GROUP BY prefecture
      UNION
      SELECT prefecture, 0 as closed, COUNT(DISTINCT station_name) AS total
      FROM station
      GROUP BY prefecture
      ) a
GROUP BY a.prefecture
ORDER BY 2 DESC;



-- FINDING THE THE NO. OF CLOSED STATIONS AND PERCENTAGE OF CLOSED STATIONS RELATIVE TO TOTAL NO. OF STATIONS-
SELECT s.prefecture, COUNT(DISTINCT station_name) AS total_no_of_station, 
	   total_closed_stations, (SUM(closed) / SUM(total)) * 100 AS percentage_closed_stations
FROM station s     
INNER JOIN (SELECT prefecture,
		COUNT(DISTINCT CASE WHEN station_status = 'closed' THEN station_name END) AS total_closed_stations 
		FROM station
		GROUP BY prefecture) AS a
		ON s.prefecture = a.prefecture
INNER JOIN (SELECT prefecture, COUNT(DISTINCT station_name) as closed, 0 as total
      FROM station
      WHERE station_status = 'CLOSED'
      GROUP BY prefecture
      UNION
      SELECT prefecture, 0 as closed, COUNT(DISTINCT station_name) AS total
      FROM station
      GROUP BY prefecture) AS b   
      ON s.prefecture = b. prefecture
GROUP BY s.prefecture
ORDER BY 4 DESC, 2 DESC;


-- Creating View for Data Visualization
CREATE VIEW CloseclosedstationinprefdStationInPref AS 
SELECT s.prefecture, COUNT(DISTINCT station_name) AS total_no_of_station, 
	   total_closed_stations, (SUM(closed) / SUM(total)) * 100 AS percentage_closed_stations
FROM station s     
INNER JOIN (SELECT prefecture,
		COUNT(DISTINCT CASE WHEN station_status = 'closed' THEN station_name END) AS total_closed_stations 
		FROM station
		GROUP BY prefecture) AS a
		ON s.prefecture = a.prefecture
INNER JOIN (SELECT prefecture, COUNT(DISTINCT station_name) as closed, 0 as total
      FROM station
      WHERE station_status = 'CLOSED'
      GROUP BY prefecture
      UNION
      SELECT prefecture, 0 as closed, COUNT(DISTINCT station_name) AS total
      FROM station
      GROUP BY prefecture) AS b   
      ON s.prefecture = b. prefecture
GROUP BY s.prefecture
ORDER BY 4 DESC, 2 DESC;




