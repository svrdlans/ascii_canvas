defmodule AC.WebApi.Fixtures do
  alias AC.WebApi.Test.Faker

  def new_request(request_name, overrides \\ %{})

  def new_request(:create_canvas, overrides) do
    %{
      "width" => overrides[:width] || Faker.generate(:integer, min: 1, max: 50),
      "height" => overrides[:height] || Faker.generate(:integer, min: 1, max: 50)
    }
  end
end
