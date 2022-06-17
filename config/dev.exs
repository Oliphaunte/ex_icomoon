import Config

# Configure your database
config :kurators, Kurators.Repo,
  username: "",
  password: "",
  hostname: "localhost",
  database: "kurators_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :kurators, KuratorsWeb.Endpoint,
  url: [host: "kurators.lvh.me"],
  https: [
    port: 4000,
    cipher_suite: :strong,
    certfile: "priv/cert/selfsigned.pem",
    keyfile: "priv/cert/selfsigned_key.pem"
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  render_errors: [
    accepts: ~w(html json),
    root_layout: {KuratorsAdmin.LayoutView, :error},
    layout: {KuratorsAdmin.LayoutView, :error},
    view: KuratorsAdmin.ErrorView
  ],
  secret_key_base: "PwoZ599kk+Ul+Q2abkJFzW0zI+wPWFxCueYlvAiwniXeq8X4Whb7yr/MHqe4zXU6",
  watchers: [
    # Start the esbuild watcher by calling Esbuild.install_and_run(:default, args)
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

config :kurators, KuratorsAdmin.Endpoint,
  url: [host: "admin.kurators.lvh.me"],
  https: [
    port: 4100,
    cipher_suite: :strong,
    certfile: "priv/cert/selfsigned.pem",
    keyfile: "priv/cert/selfsigned_key.pem"
  ],
  render_errors: [
    accepts: ~w(html json),
    root_layout: {KuratorsAdmin.LayoutView, :error},
    layout: {KuratorsAdmin.LayoutView, :error},
    view: KuratorsAdmin.ErrorView
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "whnL8JiOu6e5YIbt0mqTHL51OxbBC6DmLAzIrO0RA0LN8AyrLs1MdVtVitIUB6pJ",
  watchers: [
    # Start the esbuild watcher by calling Esbuild.install_and_run(:default, args)
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :kurators, KuratorsWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/kurators_web/(live|views)/.*(ex)$",
      ~r"lib/kurators_web/templates/.*(eex)$",
      ~r"lib/kurators_live_helpers.*(ex)$"
    ]
  ]

config :kurators, KuratorsAdmin.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/kurators_admin/(live|views)/.*(ex)$",
      ~r"lib/kurators_admin/templates/.*(eex)$",
      ~r"lib/kurators_live_helpers.*(ex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

import_config "dev.secret.exs"
