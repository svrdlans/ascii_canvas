defmodule AC.WebApi.Canvas.Requests.Create do
  @moduledoc """
  Schema for validating canvas create request.
  """

  use Ecto.Schema

  @type t() :: %__MODULE__{
          width: pos_integer(),
          height: pos_integer()
        }

  @primary_key false
  embedded_schema do
    field :width, :integer
    field :height, :integer
  end

  @spec validate(params :: map()) :: Ecto.Changeset.t()
  def validate(params) do
    fields = ~w(width height)a

    %__MODULE__{}
    |> Ecto.Changeset.cast(params, fields)
    |> Ecto.Changeset.validate_required(fields)
    |> Ecto.Changeset.validate_number(:width, greater_than: 0, less_than_or_equal_to: 50)
    |> Ecto.Changeset.validate_number(:height, greater_than: 0, less_than_or_equal_to: 50)
  end

  @spec changes(Ecto.Changeset.t()) :: t()
  def changes(%Ecto.Changeset{} = cs) do
    cs
    |> Ecto.Changeset.apply_changes()
  end
end
