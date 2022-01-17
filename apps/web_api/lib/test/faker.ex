defmodule AC.WebApi.Test.Faker do
  def generate(name, opts \\ [])

  def generate(:uuid, _opts), do: Faker.UUID.v4()

  def generate(:integer, opts) do
    min = Keyword.fetch!(opts, :min)
    max = Keyword.fetch!(opts, :max)
    Faker.random_between(min, max)
  end

  def generate(:ascii_string, opts) do
    size = Keyword.fetch!(opts, :size)

    for _ <- 1..size,
        do:
          0..127
          # non printable characters and blank
          |> Faker.Util.pick([9, 10, 11, 12, 13, 32])
          |> :binary.encode_unsigned(),
        into: ""
  end
end
