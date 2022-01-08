defmodule Mix.Tasks.Bless do
  @shortdoc "Runs all required checks, should be run before every commit"

  use Mix.Task

  @impl Mix.Task
  def run(_) do
    [
      {"format", ["--check-formatted"]},
      {"compile", ["--warnings-as-errors", "--force"]},
      {"coveralls.html", []},
      {"dialyzer", []}
    ]
    |> Enum.map(fn {task, args} ->
      IO.ANSI.format([:green, "Running task #{task} with args #{inspect(args)}"])
      |> IO.puts()

      Mix.Task.run(task, args)
    end)
  end
end
