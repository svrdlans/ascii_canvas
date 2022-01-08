defmodule AC.WebApi.Canvas.Requests.Create do
  @moduledoc """
  Schema describing a canvas.
  """

  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :width, :integer
    field :height, :integer
  end

  @spec new(params :: map()) :: Ecto.Changeset.t()
  def new(params) do
    fields = ~w(width height)a

    %__MODULE__{}
    |> Ecto.Changeset.cast(params, fields)
    |> Ecto.Changeset.validate_required(fields)
    |> Ecto.Changeset.validate_number(:width, greater_than: 0, less_than_or_equal_to: 50)
    |> Ecto.Changeset.validate_number(:height, greater_than: 0, less_than_or_equal_to: 50)
  end
end
