# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :kubeojo,
  ecto_repos: [Kubeojo.Repo]

# Configures the endpoint
config :kubeojo, Kubeojo.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "D7k8D+Qlp16LQRh+gXRBibO173gxX7lGYigOaq8TdyGAHvG2ps9/tizu5ce+nwri",
  render_errors: [view: Kubeojo.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Kubeojo.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
