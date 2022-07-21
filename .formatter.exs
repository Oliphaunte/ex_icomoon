[
  import_deps: [:ecto, :phoenix, :phoenix_live_view],
  line_length: 98,
  heex_line_length: 98,
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{heex,ex,exs}"],
  subdirectories: ["priv/*/migrations"]
]
