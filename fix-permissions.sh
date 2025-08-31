#!/bin/bash

# WordPress Permissions Fix Script
# This script sets the correct permissions for WordPress file uploads

echo "Fixing WordPress file permissions..."

# Set ownership: user as owner, www-data group (GID 33) for container access
sudo chown -R $(id -u):33 wp/

# Set permissions to allow group write access
sudo chmod -R 775 wp/

echo "Permissions fixed! WordPress should now be able to upload files."