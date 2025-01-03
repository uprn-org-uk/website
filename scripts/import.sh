#!/bin/bash

#ogr2ogr -f CSV osopenuprn_address.csv osopenuprn_202411.gpkg osopenuprn_address -select UPRN,LATITUDE,LONGITUDE

# Variables
DB_NAME="uprn"
DB_USER="uprn"
DB_PASSWORD="uprn"
CSV_FILE="osopenuprn_address.csv"

# Export Postgres password to avoid prompt (use with caution)
export PGPASSWORD=$DB_PASSWORD

# Step 2: Create the uprn_geo Table
psql -U $DB_USER -d $DB_NAME -c "
DROP TABLE IF EXISTS uprn_geo;

CREATE TABLE uprn_geo (
    uprn BIGINT PRIMARY KEY,
    latitude REAL,
    longitude REAL,
    geom geometry(Point, 4326)
);"

# Step 3: Import the CSV Data
psql -U $DB_USER -d $DB_NAME -c "\copy uprn_geo(uprn, latitude, longitude) FROM '$CSV_FILE' WITH (FORMAT csv, HEADER true)"

# Step 4: Populate the geom ColumN
psql -U $DB_USER -d $DB_NAME -c "
UPDATE uprn_geo
SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);"

# Step 5: Clean Up (Optional)
psql -U $DB_USER -d $DB_NAME -c "
ALTER TABLE uprn_geo DROP COLUMN latitude, DROP COLUMN longitude;"

# Step 6: Create a Spatial Index (Optional)
psql -U $DB_USER -d $DB_NAME -c "
CREATE INDEX uprn_geo_geom_idx ON uprn_geo USING GIST (geom);"

psql -U $DB_USER -d $DB_NAME -c "
ALTER TABLE uprn_geo ADD CONSTRAINT uprn_geo_uprn_unique UNIQUE (uprn);"

# Unset the password variable for security
unset PGPASSWORD

echo "Data import and processing completed successfully."
