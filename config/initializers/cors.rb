Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:3000', 
            'http://localhost:3001', 
            'https://example.app',
            /\Ahttps:\/\/([a-z0-9\-]+)\.yourdomain\.com\z/ # Optional: Regex for subdomains

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: ["Authorization"]
  end
end