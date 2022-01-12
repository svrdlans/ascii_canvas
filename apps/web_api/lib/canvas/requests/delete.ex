defmodule AC.WebApi.Canvas.Requests.Delete do
  @moduledoc """
  Schema for validating canvas delete request.
  """
  alias AC.WebApi.Canvas

  use Ecto.Schema

  @type t() :: %__MODULE__{id: Canvas.uuid()}

  @primary_key false
  embedded_schema do
    field :id, Ecto.UUID
  end

  @spec validate(params :: map()) :: Ecto.Changeset.t()
  def validate(params) do
    fields = [:id]

    %__MODULE__{}
    |> Ecto.Changeset.cast(params, fields)
    |> Ecto.Changeset.validate_required(fields)
  end

  @spec changes(Ecto.Changeset.t()) :: t()
  def changes(%Ecto.Changeset{} = cs) do
    cs
    |> Ecto.Changeset.apply_changes()
  end
end
