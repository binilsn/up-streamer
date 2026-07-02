Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins = ENV.fetch("ALLOWED_ORIGINS", "http://localhost:3000").split(",").map(&:strip)

    resource "/api/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "X-Total-Count", "X-Total-Pages" ],
      max_age: 600
  end
end
