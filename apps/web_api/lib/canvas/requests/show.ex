defmodule AC.WebApi.Canvas.Requests.Show do
  @moduledoc """
  Used for validating canvas show request.
  """

  alias AC.WebApi.Canvas

  use Ecto.Schema

  @type t() :: %__MODULE__{id: Canvas.uuid(), canvas: Canvas.t()}

  @primary_key false
  embedded_schema do
    field :id, Ecto.UUID
    field :canvas, :map
  end

  @not_found "not found"

  @spec validate(params :: map(), repo :: module()) :: Ecto.Changeset.t()
  def validate(params, repo) when is_atom(repo) do
    fields = [:id]

    %__MODULE__{}
    |> Ecto.Changeset.cast(params, fields)
    |> Ecto.Changeset.validate_required(fields)
    |> _validate_id_exists(repo)
  end

  @spec changes(Ecto.Changeset.t()) :: t()
  def changes(%Ecto.Changeset{} = cs) do
    cs
    |> Ecto.Changeset.apply_changes()
  end

  @spec _validate_id_exists(Ecto.Changeset.t(), module()) :: Ecto.Changeset.t()
  defp _validate_id_exists(%Ecto.Changeset{valid?: false} = cs, _),
    do: cs

  defp _validate_id_exists(%Ecto.Changeset{changes: %{id: id}} = cs, repo) do
    case repo.get(id) do
      nil -> Ecto.Changeset.add_error(cs, :id, @not_found)
      %Canvas{} = canvas -> Ecto.Changeset.put_change(cs, :canvas, canvas)
    end
  end
end
