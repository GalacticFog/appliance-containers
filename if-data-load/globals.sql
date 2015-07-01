--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE gestaltdev;
ALTER ROLE gestaltdev WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN NOREPLICATION PASSWORD 'md5cc8f2ad116c498e2c071da66932f8f89';

--
-- PostgreSQL database cluster dump complete
--

