# Up Streamer Client

A Ruby gem for sending application logs to the [Up Streamer](https://github.com/binilsn/up-streamer) log ingestion service.

## 🔧 Rails Setup (1 minute)

**1. Add to Gemfile:**

```ruby
gem 'up-streamer-client'
```

**2. Create `config/initializers/up_streamer.rb`:**

```ruby
UpStreamer.configure do |c|
  c.api_endpoint = 'http://127.0.0.1:3001/api/v1'
  c.access_token = 'your-service-token-here'
end

# Optional: forward all Rails.logger calls to the API
Rails.application.config.logger = UpStreamer::Logger.new
```

**3. Or use environment variables (no initializer needed):**

```bash
UP_STREAMER_ENDPOINT=http://127.0.0.1:3001/api/v1
UP_STREAMER_ACCESS_TOKEN=your-service-token-here
```

**That's it.** The Railtie automatically captures:

| What | How |
|---|---|
| Every controller action | ✅ Built-in — method, path, status, duration, exceptions |
| Every Active Job | ✅ Built-in — job class, ID, queue, arguments, duration |
| Explicit `Rails.logger.info(...)` calls | ✅ Only if you set `config.logger = UpStreamer::Logger.new` |

## ⚡ Send a log manually

```ruby
client = UpStreamer::Client.new
client.send_log(level: 'error', message: 'Connection timeout', hostname: 'prod-01')
```

## 📝 Send log parameters

| Param | Required | Default | Description |
|---|---|---|---|
| `message` | yes | — | Log message text |
| `level` | no | `'info'` | `debug`, `info`, `warn`, `error`, `critical` |
| `hostname` | no | — | Source hostname |
| `error_code` | no | — | Error code identifier |
| `timestamp` | no | now | ISO8601 timestamp string |
| `metadata` | no | `{}` | Arbitrary JSON object |

## 🚫 Silent failures

Timeouts, connection refused, and blank tokens fail silently (`false`). Other HTTP errors (auth, server errors) log a warning. Your app won't crash if the Up Streamer service is down.

## 💻 Development

```bash
bin/setup    # Install dependencies
bundle exec rspec    # Run tests
bundle exec rubocop  # Lint
bin/console          # Interactive console
```

## 📄 License

MIT
