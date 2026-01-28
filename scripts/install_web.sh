#!/bin/bash

# Installation of the required packages 
apt-get update
apt-get install -y apache2

# Create the custom web page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>OUTSCALE Web Server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            text-align: center;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
        }
        .server-info {
            background-color: #f0f0f0;
            padding: 20px;
            border-radius: 5px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to the OUTSCALE Web Server</h1>
        <div class="server-info">
            <p>Hostname: $(hostname)</p>
            <p>IP: $(hostname -I | cut -d' ' -f1)</p>
            <p>Date: $(date)</p>
        </div>
    </div>
</body>
</html>
EOF

# Configuration of permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Starting the Apache service
systemctl enable apache2
systemctl start apache2