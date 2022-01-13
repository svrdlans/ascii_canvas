defmodule AC.WebApi.Fixtures do
  alias AC.WebApi.Test.Faker

  def new_request(request_name, overrides \\ %{})

  def new_request(:create_canvas, overrides) do
    %{
      "width" => overrides[:width] || Faker.generate(:integer, min: 1, max: 50),
      "height" => overrides[:height] || Faker.generate(:integer, min: 1, max: 50)
    }
  end

  def new_request(:draw_rectangle, overrides) do
    coords =
      overrides[:coords] ||
        [Faker.generate(:integer, min: 0, max: 50), Faker.generate(:integer, min: 0, max: 50)]

    %{
      "id" => overrides[:id] || Faker.generate(:uuid),
      "coords" => coords,
      "width" => overrides[:width] || Faker.generate(:integer, min: 1, max: 50),
      "height" => overrides[:height] || Faker.generate(:integer, min: 1, max: 50),
      "outline" => Map.get(overrides, :outline, Faker.generate(:ascii_string, size: 1)),
      "fill" => Map.get(overrides, :fill, Faker.generate(:ascii_string, size: 1))
    }
  end
end
