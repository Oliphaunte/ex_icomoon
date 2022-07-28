defmodule Mix.Tasks.Kurators.Add do
  @moduledoc """
  """

  use Mix.Task
  require IEx

  @shortdoc "Adds Kurators to your project"

  @doc """
  Add the app name to config
  """
  def config_names(config) do
    inflected =
      Mix.Phoenix.otp_app()
      |> to_string()
      |> Mix.Phoenix.inflect()

    config
    |> Map.put(:path, inflected[:path])
    |> Map.put(:main_module, inflected[:base])
    |> Map.put(:web_module, inflected[:web_module])
    |> Map.put(:admin_module, inflected[:base] <> "Admin")
  end

  @doc """
  Add the main paths of the application to config

  admin_path is a custom path to the admin module
  """
  def config_paths(config) do
    admin_path = Path.join(["lib", config[:path] <> "_admin"])
    web_path = Path.join(["lib", config[:path] <> "_web"])
    main_path = Path.join(["lib", config[:path]])
    config_path = Path.join(["config", "config.exs"])
    migration_path = Path.join(["priv", "repo", "migrations", "#{timestamp()}_add_veil.exs"])
    layout_path = Path.join([web_path, "templates", "layout", "app.html.eex"])
    web_router_path = Path.join([web_path, "router.ex"])
    admin_router_path = Path.join([admin_path, "router.ex"])

    config
    |> Map.put(:main_path, main_path)
    |> Map.put(:web_path, web_path)
    |> Map.put(:admin_path, admin_path)
    |> Map.put(:config_path, config_path)
    |> Map.put(:migration_path, migration_path)
    |> Map.put(:layout_path, layout_path)
    |> Map.put(:web_router_path, web_router_path)
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)

  @doc """
  Adds salts for the request/session internal tokens. These should only ever be saved in the
  database, so do not actually need to be this random.
  """
  def config_secrets(config) do
    config
    |> Map.put(:request_salt, random_salt())
    |> Map.put(:session_salt, random_salt())
  end

  def random_salt do
    :crypto.strong_rand_bytes(23 + :rand.uniform(17))
    |> Base.encode64()
  end

  def config_html?(%{web_path: web_path} = config) do
    template_path = Path.join(web_path, "templates")

    case File.lstat(template_path) do
      {:ok, %{type: :directory}} ->
        Map.put(config, :html?, true)

      _ ->
        Map.put(config, :html?, false)
    end
  end

  @doc """
  Set up the config map
  """
  def config do
    %{}
    |> config_names()
    |> config_paths()
    |> config_secrets()
    |> config_html?()
  end

  @doc """
  Verify the paths all exist
  """
  def verify_paths(config) do
    %{main_path: main_path, web_path: web_path, admin_path: admin_path, config_path: config_path} =
      config

    with {:ok, %{type: :directory}} <- File.lstat(main_path),
         {:ok, %{type: :directory}} <- File.lstat(admin_path),
         {:ok, %{type: :directory}} <- File.lstat(web_path),
         {:ok, %{type: :regular}} <- File.lstat(config_path) do
      config
    else
      _ ->
        Mix.raise("Cannot find all paths: #{main_path}, #{web_path}, #{config_path}")
    end
  end

  @doc """
  Gives the source path to copy files from
  """
  def source_path(path) do
    Application.app_dir(:veil, Path.join(["priv", "templates", path]))
  end

  @doc """
  """
  def append_config_file(%{config_path: config_path} = config) do
    config_source = source_path(Path.join(["config", "config.exs"]))

    # if File.exists?(config_path) and File.exists?(config_source) do
    #   previous = File.read!(config_path)
    #   config_data = EEx.eval_file(config_source, config |> Map.to_list())

    #   confirmed =
    #     if String.contains?(previous, "-- Kurators Configuration") do
    #       Mix.shell().yes?(
    #         "Your config file already contains Kurators configuration. Are you sure you want to add another?"
    #       )
    #     else
    #       true
    #     end

    #   if confirmed do
    #     File.write!(config_path, previous <> "\n\n" <> config_data)

    #     Mix.shell().info([
    #       :yellow,
    #       "* amended ",
    #       :reset,
    #       "config/config.exs - Veil config added"
    #     ])
    #   else
    #     Mix.shell().info([
    #       :yellow,
    #       "* skipping ",
    #       :reset,
    #       "config/config.exs - Veil config skipped"
    #     ])
    #   end

    #   config
    # else
    #   Mix.raise("Cannot find config file at: #{config_path} or #{config_source}")
    # end
  end

  def run(_args) do
    Mix.shell().info([:cyan, "\n Adding Kurators to your project...\n"])

    # Mix.shell().yes?()

    config()
    |> verify_paths()
  end
end
