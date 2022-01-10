defmodule AC.WebApi.Test.Faker do
  def generate(:uuid), do: Faker.UUID.v4()
end
