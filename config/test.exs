import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :repo_doc_helper, RepoDocHelperWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "zIjh+dqaK4sAcwt4cMbzmnmv20eOWXklKQPEz9I0Z+TjS32DaJR9O+ypHBF6kUoI",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
