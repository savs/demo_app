# Demo Application with OpenTelemetry

This demo application consists of a PHP web application and a Ruby on Rails web application, both instrumented with OpenTelemetry and configured to send telemetry data to Grafana Alloy for collection and forwarding.

## Prerequisites

- Docker and Docker Compose
- Bash shell (for running scripts)

## Quick Start

### 1. Configure Environment Variables

Copy the `.env_template` file to `.env`:

```bash
cp .env_template .env
```

Edit the `.env` file and configure the following variables based on your Grafana Cloud setup:

#### Required for Grafana Cloud Integration

- **`OTLP_ENDPOINT`**: Your Grafana Cloud OTLP endpoint (e.g., `https://otlp-gateway-prod-us-central-0.grafana.net/otlp`)
- **`OTLP_USERNAME`**: Your Grafana Cloud instance ID
- **`OTLP_PASSWORD`**: Your Grafana Cloud API key

#### Optional Configuration

- **`SERVICE_VERSION`**: Version tag for your services (defaults to `1.0.0`)
- **`OTEL_EXPORTER_OTLP_HEADERS`**: Additional OTLP headers (comma-separated key=value pairs)

#### Other Services (Optional)

The following variables are available for additional integrations but are not required for basic operation:

- **Grafana Cloud Metrics/Logs**:
  - `METRICS_SERVICE_URL`
  - `METRICS_SERVICE_USERNAME`
  - `LOGS_SERVICE_URL`
  - `LOGS_SERVICE_USERNAME`

- **Grafana Cloud Remote Config**:
  - `GCLOUD_TOKEN`
  - `GCLOUD_RW_API_KEY`
  - `GCLOUD_FM_COLLECTOR_ID`
  - `GCLOUD_REMOTECFG_ID`
  - `GCLOUD_REMOTECFG_USERNAME`

- **Beyla**:
  - `BEYLA_TOKEN`

- **App Token**:
  - `APP_TOKEN`

- **Pyroscope**:
  - `PYROSCOPE_ENDPOINT`
  - `PYROSCOPE_USERNAME`
  - `PYROSCOPE_PASSWORD`

- **k6 Cloud**:
  - `K6_TOKEN`
  - `K6_CLOUD_PROJECT_ID`

### 2. Start the Application

#### Option A: Using the start script

```bash
./start.sh
```

#### Option B: Using Docker Compose directly

```bash
docker compose up --build -d
```

### 3. Access the Applications

Once started, the applications will be available at:

- **PHP App**: http://localhost:8080
- **Ruby on Rails App**: http://localhost:3000
- **Grafana Alloy UI**: http://localhost:12345

## Application Details

### PHP Application

- **Port**: 8080
- **Service Name**: `php-web`
- **Framework**: PHP with OpenTelemetry instrumentation
- **Features**:
  - OpenTelemetry traces exported to Alloy
  - Displays server time and PHP version

### Ruby on Rails Application

- **Port**: 3000
- **Service Name**: `ruby-app`
- **Framework**: Ruby on Rails 7.1+
- **Features**:
  - OpenTelemetry traces exported to Alloy
  - OpenTelemetry logs exported to Alloy
  - Request logging middleware that logs each HTTP request with trace context
  - Displays server time, Ruby version, Rails version, and all OTEL_ environment variables
  - **Pagila sample database**: browse films, actors, categories, and customers at http://localhost:3000/pagila

#### If you see "We could not find your database: pagila"

Postgres only runs the Pagila init script when the data directory is empty. If the Postgres container was previously started (e.g. before the init script was fixed), the `pagila` database was never created. Remove the volume and start again so init runs:

```bash
docker compose down -v
docker compose up
```

The first startup may take 1–2 minutes while the Pagila schema and data are downloaded and loaded.

## Generating Load

To generate continuous load on both applications, use the load generator script:

```bash
./load.sh [concurrency]
```

**Parameters**:
- `concurrency` (optional): Number of concurrent workers per app (default: 5)

**Example**:
```bash
./load.sh 10  # Run with 10 concurrent workers per app
```

The script will:
- Send requests to both PHP and Ruby apps
- Use random delays between 0-3 seconds
- Display approximate request counts every 5 seconds
- Continue until you press Ctrl+C

## Viewing Logs

### View all logs
```bash
docker compose logs -f
```

### View logs for a specific service
```bash
docker compose logs -f ruby-app
docker compose logs -f php-app
docker compose logs -f alloy
```

## Stopping the Application

```bash
docker compose down
```

Or to remove volumes as well:

```bash
docker compose down -v
```

## OpenTelemetry Configuration

Both applications are configured to send telemetry data to Grafana Alloy, which then forwards it to your configured endpoint (typically Grafana Cloud).

### Trace Configuration

- **Exporter**: OTLP (HTTP/Protobuf)
- **Endpoint**: `http://alloy:4318` (internal to Docker network)
- **Exporters**: `console,otlp` (logs to console and sends via OTLP)

### Log Configuration (Ruby App)

- **Exporter**: OTLP
- **Endpoint**: `http://alloy:4318` (internal to Docker network)
- **Request Logging**: Each HTTP request is logged with trace context

### Resource Attributes

Both services include the following resource attributes:
- `service.name`: Service identifier
- `service.namespace`: `demo`
- `deployment.environment`: `development`
- `service.version`: From `SERVICE_VERSION` environment variable

## Troubleshooting

### Applications not starting

1. Check if ports are already in use:
   ```bash
   lsof -i :8080  # PHP app
   lsof -i :3000  # Ruby app
   lsof -i :12345 # Alloy
   ```

2. Check Docker logs:
   ```bash
   docker compose logs
   ```

### OpenTelemetry data not appearing

1. Verify `.env` file is configured correctly
2. Check Alloy logs for connection issues:
   ```bash
   docker compose logs alloy
   ```
3. Verify Alloy configuration in `alloy/config.alloy`
4. Check that OTLP endpoint and credentials are correct

### Build failures

1. Ensure Docker has enough resources allocated
2. Try rebuilding without cache:
   ```bash
   docker compose build --no-cache
   ```

## Project Structure

```
demo_app/
├── .env_template          # Template for environment variables
├── .env                   # Your environment configuration (create from template)
├── docker-compose.yml     # Docker Compose configuration
├── start.sh              # Startup script
├── load.sh               # Load generator script
├── alloy/                # Grafana Alloy configuration
│   └── config.alloy
├── PHP/                  # PHP application
│   ├── Dockerfile
│   ├── index.php
│   └── opentelemetry-init.php
└── Ruby/                 # Ruby on Rails application
    ├── Dockerfile
    ├── Gemfile
    ├── app/
    │   ├── controllers/
    │   └── middleware/
    └── config/
        └── initializers/
```

## License

See the [LICENSE](LICENSE) file for details.
