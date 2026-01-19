#!/bin/bash

# Installation des paquets nécessaires
apt-get update
apt-get install -y apache2

# Création de la page web personnalisée
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Serveur Web OUTSCALE</title>
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
        <h1>Bienvenue sur le serveur web OUTSCALE</h1>
        <div class="server-info">
            <p>Hostname: $(hostname)</p>
            <p>IP: $(hostname -I | cut -d' ' -f1)</p>
            <p>Date: $(date)</p>
        </div>
    </div>
</body>
</html>
EOF

# Configuration des droits
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Démarrage du service Apache
systemctl enable apache2
systemctl start apache2