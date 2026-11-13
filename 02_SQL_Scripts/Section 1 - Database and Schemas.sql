IF DB_ID('EcommerceDW') IS NULL CREATE DATABASE EcommerceDW;
GO
USE EcommerceDW;
GO
IF SCHEMA_ID('stg')  IS NULL EXEC('CREATE SCHEMA stg');   -- staging + cleaning views
IF SCHEMA_ID('dw')   IS NULL EXEC('CREATE SCHEMA dw');    -- enterprise data warehouse
IF SCHEMA_ID('mart') IS NULL EXEC('CREATE SCHEMA mart');  -- data mart
GO