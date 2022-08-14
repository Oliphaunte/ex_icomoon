defmodule Kurators.LogFormatter do
  @protected [:request_id]

  def format(level, message, timestamp, metadata) do
    {:ok, "##### #{fmt_timestamp(timestamp)} [#{level}] #{message}\n"}
  rescue
    _ ->
      error = "could not format message: \n
      level: #{inspect({level})} \n
      message: #{inspect({message})} \n
      timestamp: #{inspect({timestamp})} \n
      metadata: #{inspect({metadata})} \n"

      {:error, error}
  end

  defp fmt_metadata(md) do
    md
    # |> Keyword.keys()
    # |> Enum.map(&output_metadata(md, &1))
    # |> Enum.join(" ")
  end

  def output_metadata(metadata, key) do
    if Enum.member?(@protected, key) do
      "#{key}=(REDACTED)"
    else
      IO.inspect("#{metadata[key]}")
      "#{key}=#{metadata[key]}"
    end
  end

  defp fmt_timestamp({date, {hh, mm, ss, ms}}) do
    with {:ok, timestamp} <- NaiveDateTime.from_erl({date, {hh, mm, ss}}, {ms * 1000, 3}),
         result <- NaiveDateTime.to_iso8601(timestamp) do
      "#{result}Z"
    end
  end
end
