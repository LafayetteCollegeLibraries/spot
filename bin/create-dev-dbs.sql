-- create the user + database for fedora's internal postgres db.
-- NOTE: the database name is hardcoded as "fcrepo"
CREATE USER spot_fcrepo_dev_user WITH password 'spot_fcrepo_dev_pw';
CREATE DATABASE fcrepo OWNER spot_fcrepo_dev_user;
GRANT ALL PRIVILEGES ON DATABASE fcrepo TO spot_fcrepo_dev_user;

-- create the extra database for our test suites
CREATE DATABASE spot_test OWNER spot_dev_user;
