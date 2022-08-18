# ExIcomoon

**TODO: Add description**

A simple helper to allow you to use icomoon on your projects

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_icomoon` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_icomoon, "~> 0.1.0"}
  ]
end
```

## Usage

1. You will need to make sure you copy & paste your cdn url for your icomoon set(s), in `root.html.heex`
2. Import the Helper into your web entrypoint:
```
  defp view_helpers do
    quote do
      ...

      import ExIcomoon
    end
  end
```
3. You can now call the <.icon> helper anywhere in your heex files. 
```
<.icon name="your_icon">
```

