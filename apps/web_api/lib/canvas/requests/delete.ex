defmodule AC.WebApi.Canvas.Requests.Delete do
  @moduledoc """
  Schema for validating canvas delete request.
  """
  alias AC.WebApi.Canvas
  alias AC.WebApi.Repo

  use Ecto.Schema

  @type t() :: %__MODULE__{id: Canvas.uuid()}

  @primary_key false
  embedded_schema do
    field :id, Ecto.UUID
  end

  @not_found "not found"

  @spec validate(params :: map()) :: Ecto.Changeset.t()
  def validate(params) do
    fields = [:id]

    %__MODULE__{}
    |> Ecto.Changeset.cast(params, fields)
    |> Ecto.Changeset.validate_required(fields)
    |> _validate_id_exists()
  end

  @spec changes(Ecto.Changeset.t()) :: t()
  def changes(%Ecto.Changeset{} = cs) do
    cs
    |> Ecto.Changeset.apply_changes()
  end

  @spec _validate_id_exists(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp _validate_id_exists(%Ecto.Changeset{valid?: false} = cs),
    do: cs

  defp _validate_id_exists(%Ecto.Changeset{changes: %{id: id}} = cs) do
    if Repo.exists?(id) do
      cs
    else
      Ecto.Changeset.add_error(cs, :id, @not_found)
    end
  end
end
