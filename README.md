# Docker WordPress Development Environment

A containerized WordPress development environment using Docker Compose with nginx, PHP 8.2-FPM, MariaDB, and Adminer.

## Features

- **nginx**: Web server with automatic WordPress download and HTTPS redirect support
- **PHP 8.2-FPM**: Optimized for WordPress with Redis, Imagick, and MySQL extensions
- **MariaDB**: Database backend with automatic WordPress database creation
- **Adminer**: Web-based database administration tool
- **Volume Persistence**: WordPress files and database data persist between container restarts

## Quick Start

### Prerequisites

- Docker and Docker Compose installed on your system
- Basic understanding of WordPress and Docker

### 1. Clone and Setup

```bash
git clone <repository-url>
cd docker-wp
```

### 2. Environment Configuration

Copy the sample environment file and customize as needed:

```bash
cp .env.sample .env
```

Edit `.env` with your preferred settings:

```env
SERVER_NAME=wordpress.local
MYSQL_PASSWORD=your_secure_password
WP_DB=wp
WP_DB_USER=wp
WP_DB_USER_PASS=your_secure_password
```

### 3. Fix Permissions

Set correct file permissions for WordPress uploads:

```bash
./fix-permissions.sh
```

### 4. SSL/HTTPS Setup (Optional)

This project includes automated SSL certificate generation using mkcert for local development.

### Generate SSL Certificates

Run the included script to generate trusted local SSL certificates:

```bash
./generate-ssl.sh
```

This script will:

1. Use the `alpine/mkcert` Docker image to install the local CA
2. Generate SSL certificates for your domain (from SERVER_NAME in .env)
3. Place certificates in the `./ssl/` directory

#### Enable SSL

After generating certificates, restart the environment:

```bash
docker-compose down && docker-compose up -d
```

Your site will now be available at:

- `https://wordpress.local` (or your SERVER_NAME)
- HTTP requests will automatically redirect to HTTPS

#### Trust the Certificate Authority

The first time you run `./generate-ssl.sh`, you may need to trust the mkcert CA:

##### Linux

```bash
# The script will prompt you to trust the CA
# Follow the on-screen instructions
```

##### macOS

```bash
# The script will automatically add the CA to your keychain
# You may need to enter your password
```

##### Windows

```bash
# Run the script in an elevated command prompt
# The CA will be added to the Windows certificate store
```

**Important**: After generating SSL certificates and trusting the CA, you may need to restart your browser for the certificate authority to be recognized and the SSL certificates to be trusted.

#### Manual Certificate Installation

If you prefer to use your own certificates, place them in the `ssl/` directory:

- Certificate: `ssl/${SERVER_NAME}.pem`
- Private Key: `ssl/${SERVER_NAME}-key.pem`

### 5. Hosts File Configuration

Add your chosen domain to your system's hosts file to point to localhost:

#### Linux/macOS

```bash
sudo echo "127.0.0.1 wordpress.local" >> /etc/hosts
```

Or manually edit `/etc/hosts`:

```
127.0.0.1 wordpress.local
```

#### Windows

1. Open Notepad as Administrator
2. Open `C:\Windows\System32\drivers\etc\hosts`
3. Add this line:

```
127.0.0.1 wordpress.local
```

4. Save the file

### 6. Start the Environment

```bash
# Start all services
docker-compose up -d

# View logs (optional)
docker-compose logs -f
```

### 7. WordPress Installation

1. Open your browser and navigate to `http://wordpress.local` (or your chosen domain)
2. Follow the WordPress installation wizard with these database settings:
   - **Database Name**: `wp` (or your WP_DB value)
   - **Username**: `wp` (or your WP_DB_USER value)
   - **Password**: Your WP_DB_USER_PASS value
   - **Database Host**: `db`
   - **Table Prefix**: `wp_` (default)

## Service Details

### Ports

- **HTTP**: 80 (WordPress site)
- **HTTPS**: 443 (WordPress site, requires SSL setup)
- **Adminer**: 8080 (Database admin interface)

### URLs

- WordPress: `http://wordpress.local` (or your SERVER_NAME)
- Adminer: `http://localhost:8080`

## Development Workflow

### Custom Themes and Plugins

Place your custom WordPress themes and plugins in the `./wp/` directory:

```
./wp/
├── themes/
│   └── your-custom-theme/
└── plugins/
    └── your-custom-plugin/
```

These will be automatically mounted to `/wp-content/` in the WordPress installation.

### Database Access

**Via Adminer (Recommended)**:

- URL: `http://localhost:8080`
- System: MySQL
- Server: `db`
- Username: Your WP_DB_USER value
- Password: Your WP_DB_USER_PASS value
- Database: Your WP_DB value

**Via Command Line**:

```bash
docker-compose exec db mysql -u wp -p wp
```

### Container Management

```bash
# View running containers
docker-compose ps

# View logs for specific service
docker-compose logs nginx
docker-compose logs php
docker-compose logs db

# Restart services
docker-compose restart

# Stop all services
docker-compose down

# Stop and remove volumes (reset everything)
docker-compose down -v

# Rebuild containers
docker-compose up --build -d
```

### File Structure

```
docker-wp/
├── nginx/
│   ├── Dockerfile
│   └── nginx.conf.template
├── php8.2/
│   ├── Dockerfile
│   └── php.ini
├── wp/                     # WordPress themes/plugins
│   ├── themes/
│   └── plugins/
├── .env.sample
├── .env                    # Your environment variables
├── .gitignore
├── compose.yaml
└── README.md
```

## Troubleshooting

### WordPress Installation Issues

- Ensure all containers are running: `docker-compose ps`
- Check database connectivity: `docker-compose logs db`
- Verify hosts file entry matches your SERVER_NAME

### Permission Issues

If you encounter file upload errors or permission issues, run the permissions fix script:

```bash
./fix-permissions.sh
```

This script sets the correct ownership (your user as owner, www-data group for container access) and permissions for WordPress file operations.

### Database Issues

```bash
# Reset database (WARNING: destroys all data)
docker-compose down -v
docker-compose up -d
```

### Container Logs

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f nginx
```

## Environment Variables

| Variable          | Description                         | Default           |
| ----------------- | ----------------------------------- | ----------------- |
| `SERVER_NAME`     | Domain name for nginx configuration | `wordpress.local` |
| `MYSQL_PASSWORD`  | MariaDB root password               | `test`            |
| `WP_DB`           | WordPress database name             | `wp`              |
| `WP_DB_USER`      | WordPress database username         | `wp`              |
| `WP_DB_USER_PASS` | WordPress database password         | `test`            |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the environment
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).
