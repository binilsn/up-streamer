# Up Streamer Client

A Ruby gem for sending application logs to the [Up Streamer](https://github.com/binilsn/up-streamer) log ingestion service.

## Installation

Add to your Gemfile:

```ruby
gem 'up-streamer-client'
```

Or build from source:

```bash
cd up-streamer-client
gem build up-streamer-client.gemspec
gem install up-streamer-client-0.1.0.gem
```

## Usage

### 1. Configure

```ruby
require 'up-streamer-client'

UpStreamer.configure do |c|
  # Required — the URL of your Up Streamer API
  c.api_endpoint = 'https://your-app.com/api/v1'

  # Required — an access token from the Services page (/services)
  c.access_token = 'your-service-token-here'
end
```

### 2. Send a log

```ruby
client = UpStreamer::Client.new
client.send_log(level: 'error', message: 'Connection timeout', hostname: 'prod-01')
```

### 3. Use as a drop-in Ruby Logger

```ruby
logger = UpStreamer::Logger.new
logger.info('User signed in')
logger.warn('Rate limit approaching')
logger.error('Payment failed')
```

Each call sends a `POST /api/v1/logs` request with the message and severity level.

### 4. Rails auto-integration

If Rails is present, the Railtie automatically subscribes to `process_action.action_controller` notifications and sends a log for every request:

```ruby
# config/application.rb
config.up_streamer.access_token = 'your-token'
config.up_streamer.api_endpoint = 'https://your-app.com/api/v1'
```

Or set via environment variables. No manual instrumentation needed — controller actions, status codes, durations, and exceptions are logged automatically.

## Client options

```ruby
# Override endpoint/token per instance
client = UpStreamer::Client.new(
  endpoint: 'https://staging.example.com/api/v1',
  token:    'staging-token'
)

client.send_log(level: 'info', message: 'Deploy started')
```

## Send log parameters

| Param | Required | Default | Description |
|---|---|---|---|
| `message` | yes | — | Log message text |
| `level` | no | `'info'` | `debug`, `info`, `warn`, `error`, `critical` |
| `hostname` | no | — | Source hostname |
| `error_code` | no | — | Error code identifier |
| `timestamp` | no | now | ISO8601 timestamp string |
| `metadata` | no | `{}` | Arbitrary JSON object |

## Development

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Lint
bundle exec rubocop

# Open console with gem loaded
bin/console
```

## License

MIT
