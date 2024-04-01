# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:3000", "http://localhost:5173", "https://main--war-games.netlify.app", "https://baberuth.app", "https://www.baberuth.app", "https://immense-temple-53760-309cb2c4c494.herokuapp.com", "https://war-games-2-0-api-red-tree-4407.fly.dev"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
