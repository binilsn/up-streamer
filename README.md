# Up Streamer

A centralized log ingestion and monitoring dashboard built with Rails 8.1. Services send logs via a REST API, and the dashboard provides real-time visibility, search, and system-level metrics.

## Features

### Server (this repo)
- **REST API** — Ingest, list, and retrieve logs with Bearer token authentication.
- **Dashboard** — System overview with total events, error rate, active alerts, and P99 latency.
- **Explorer** — Full-text search and filter logs by level, service, hostname, error code, and time range.
- **Live Stream** — Real-time log streaming view with severity filtering.
- **Services Management** — Register services, copy access tokens, and regenerate tokens.
- **Self-service API Reference** — Interactive documentation at `/doc`.

### Client Gem (`up-streamer-client`)
- **REST client** — Faraday-based client with configurable retry and timeouts.
- **Rails auto-instrumentation** — Automatically captures every controller action and Active Job via `ActiveSupport::Notifications`.
- **Drop-in logger** — Use `UpStreamer::Logger` as a direct replacement for `Rails.logger`.
- **Silent failures** — Network errors and timeouts never crash your application.

## Requirements

- **Ruby** 4.0.5+
- **PostgreSQL** 16+
- **Rails** 8.1 (server)
- **Bundler**

## Quick Start (Server)

```bash
git clone https://github.com/binilsn/up-streamer.git
cd up-streamer
bundle install
bin/rails db:create db:migrate
bin/rails server
```

The server starts on `http://localhost:3000`.

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `DATABASE_URL` | — | PostgreSQL connection string |
| `PORT` | `3000` | Puma listen port |

## Client Gem

The `up-streamer-client` gem sends logs from your Ruby or Rails application to the Up Streamer API.

### Install via Git

Add this to your `Gemfile`:

```ruby
gem 'up-streamer-client', github: 'binilsn/up-streamer', glob: 'up-streamer-client/*.gemspec'
```

Then run:

```bash
bundle install
```

### Configure

Create `config/initializers/up_streamer.rb`:

```ruby
UpStreamer.configure do |c|
  c.api_endpoint = 'http://127.0.0.1:3001/api/v1'
  c.access_token = 'your-service-token-here'
end

# Optional: forward all Rails.logger calls to the API
Rails.application.config.logger = UpStreamer::Logger.new
```

Or use environment variables:

```bash
UP_STREAMER_ENDPOINT=http://127.0.0.1:3001/api/v1
UP_STREAMER_ACCESS_TOKEN=your-service-token-here
```

### What Gets Captured Automatically

| Event | How |
|---|---|
| Every controller action | ✅ Built-in — method, path, status, duration, exceptions |
| Every Active Job | ✅ Built-in — job class, ID, queue, arguments, duration |
| Explicit `Rails.logger.info(...)` calls | ✅ Only if you set `config.logger = UpStreamer::Logger.new` |

### Send a Log Manually

```ruby
client = UpStreamer::Client.new
client.send_log(
  level: 'error',
  message: 'Connection timeout',
  hostname: 'prod-01',
  error_code: 'TIMEOUT_500',
  metadata: { region: 'us-east-1' }
)
```

### Log Parameters

| Param | Required | Default | Description |
|---|---|---|---|
| `message` | yes | — | Log message text |
| `level` | no | `'info'` | `debug`, `info`, `warn`, `error`, `critical` |
| `hostname` | no | — | Source hostname |
| `error_code` | no | — | Error code identifier |
| `timestamp` | no | now | ISO8601 timestamp string |
| `metadata` | no | `{}` | Arbitrary JSON object |

### Silent Failures

Timeouts, connection refused, and blank tokens return `false` silently. Other HTTP errors (auth, server errors) log a warning. Your application never crashes if the Up Streamer service is unreachable.

## API

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/logs` | Ingest a log entry |
| `GET` | `/api/v1/logs` | List logs (paginated, filterable) |
| `GET` | `/api/v1/logs/:id` | Retrieve a single log entry |

All requests require a Bearer token:

```
Authorization: Bearer <your_access_token>
```

Full interactive documentation is available at `/doc` on the running server.

## Development (Client Gem)

```bash
cd up-streamer-client
bin/setup          # Install dependencies
bundle exec rspec  # Run tests
bundle exec rubocop # Lint
bin/console        # Interactive console
```

## License

MIT License — see [LICENSE](LICENSE).
