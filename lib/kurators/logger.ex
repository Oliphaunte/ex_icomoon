defmodule Kurators.Logger do
  @moduledoc """
  Handles incoming Logger messages
  """

  @logger_path Path.join([:code.priv_dir(:kurators), "static", "logger"])

  def init({__MODULE__, name}) do
    {:ok, configure(name, [])}
  end

  defp configure(name, []) do
    base_level = Application.get_env(:logger, :level, :debug)
    Application.get_env(:logger, name, []) |> Enum.into(%{name: name, level: base_level})
  end

  defp configure(_name, [level: new_level], state) do
    Map.merge(state, %{level: new_level})
  end

  defp configure(_name, _opts, state), do: state

  def handle_call({:configure, opts}, %{name: name} = state) do
    {:ok, :ok, configure(name, opts, state)}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  # Handle any log messages that are sent across
  def handle_event(
        {level, _group_leader, {Logger, message, timestamp, metadata}},
        %{level: min_level} = state
      ) do
    if right_log_level?(min_level, level) do
      case Kurators.LogFormatter.format(level, message, timestamp, metadata) do
        {:ok, response} -> write_to_logs(response)
        {:error, error} -> IO.puts(error)
      end
    end

    {:ok, state}
  end

  defp write_to_logs(response) do
    if !File.exists?(Path.join([@logger_path, "logfile.txt"])) do
      File.touch!(Path.join([@logger_path, "logfile.txt"]))
    end

    File.write(Path.join([@logger_path, "logfile.txt"]), response, [:append])
  end

  defp right_log_level?(nil, _level), do: true

  defp right_log_level?(min_level, level) do
    Logger.compare_levels(level, min_level) != :lt
  end
end
