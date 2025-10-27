-- Initialize TodoDemo Database
-- This script runs automatically when the MySQL container starts for the first time

USE tododb;

-- Grant all privileges to the username user
GRANT ALL PRIVILEGES ON tododb.* TO 'username'@'%';
FLUSH PRIVILEGES;

-- Create indexes for better performance (Spring JPA will create tables automatically)
-- These will be applied after tables are created by Hibernate

-- Log initialization
SELECT 'TodoDemo database initialized successfully' as status;