defmodule AC.WebApi.Canvas.Requests.DrawRectangle do
  @moduledoc """
  Used to validate a request to draw a rectangle.
  """

  alias AC.WebApi.Canvas
  alias AC.WebApi.Repo

  use Ecto.Schema

  @type t() :: %__MODULE__{
          id: Canvas.uuid(),
          coords: [non_neg_integer()],
          width: pos_integer(),
          height: pos_integer(),
          outline: String.t(),
          fill: String.t()
        }

  @primary_key false
  embedded_schema do
    field :id, Ecto.UUID
    field :coords, {:array, :integer}
    field :width, :integer
    field :height, :integer
    field :outline, :string
    field :fill, :string
  end

  @not_found "not found"

  @spec validate(params :: map()) :: Ecto.Changeset.t()
  def validate(params) do
    required_fields = ~w(id coords width height)a
    optional_fields = ~w(outline fill)a

    %__MODULE__{}
    |> Ecto.Changeset.cast(params, required_fields ++ optional_fields)
    |> Ecto.Changeset.validate_required(required_fields)
    |> _validate_id_exists()
    |> Ecto.Changeset.validate_length(:coords, is: 2)
    |> _validate_number(:coords)
    |> _validate_number(:width)
    |> _validate_number(:height)
    |> _validate_if_present(:outline)
    |> _validate_if_present(:fill)
    |> _validate_one_exists(~w(outline fill)a)
  end

  @spec changes(Ecto.Changeset.t()) :: t()
  def changes(%Ecto.Changeset{} = cs) do
    cs
    |> Ecto.Changeset.apply_changes()
  end

  @spec _validate_id_exists(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp _validate_id_exists(%Ecto.Changeset{valid?: false} = cs),
    do: cs

  defp _validate_id_exists(%Ecto.Changeset{changes: %{id: id}, params: params} = cs) do
    case Repo.get(id) do
      nil ->
        Ecto.Changeset.add_error(cs, :id, @not_found)

      %{width: width, height: height} ->
        %{
          cs
          | params:
              params
              |> Map.merge(%{"__canvas_max_x" => width - 1, "__canvas_max_y" => height - 1})
        }
    end
  end

  @spec _validate_number(Ecto.Changeset.t(), atom()) :: Ecto.Changeset.t()
  defp _validate_number(%Ecto.Changeset{valid?: false} = cs, _field), do: cs

  defp _validate_number(
         %Ecto.Changeset{
           changes: %{coords: [x, y]},
           params: %{"__canvas_max_x" => max_x, "__canvas_max_y" => max_y}
         } = cs,
         :coords
       ) do
    with {:x, true} <- {:x, x >= 0 and x <= max_x},
         {:y, true} <- {:y, y >= 0 and y <= max_y} do
      cs
    else
      {:x, _} ->
        Ecto.Changeset.add_error(cs, :coords, "x coordinate must be between 0 and %{max_x}",
          max_x: max_x
        )

      {:y, _} ->
        Ecto.Changeset.add_error(cs, :coords, "y coordinate must be between 0 and %{max_y}",
          max_y: max_y
        )
    end
  end

  defp _validate_number(
         %Ecto.Changeset{
           changes: %{coords: [x, _]},
           params: %{"__canvas_max_x" => canvas_max_x}
         } = cs,
         :width
       ) do
    max_value = canvas_max_x - x + 1
    Ecto.Changeset.validate_number(cs, :width, greater_than: 0, less_than_or_equal_to: max_value)
  end

  defp _validate_number(
         %Ecto.Changeset{
           changes: %{coords: [_, y]},
           params: %{"__canvas_max_y" => canvas_max_y}
         } = cs,
         :height
       ) do
    max_value = canvas_max_y - y + 1
    Ecto.Changeset.validate_number(cs, :height, greater_than: 0, less_than_or_equal_to: max_value)
  end

  @spec _validate_if_present(Ecto.Changeset.t(), atom()) :: Ecto.Changeset.t()
  defp _validate_if_present(%Ecto.Changeset{valid?: true, changes: changes} = cs, field)
       when is_map_key(changes, field) do
    cs
    |> Ecto.Changeset.validate_length(field, is: 1)
    |> _validate_ascii(field)
  end

  defp _validate_if_present(%Ecto.Changeset{} = cs, _field), do: cs

  @spec _validate_ascii(Ecto.Changeset.t(), atom()) :: Ecto.Changeset.t()
  defp _validate_ascii(%Ecto.Changeset{valid?: false} = cs, _field), do: cs

  defp _validate_ascii(%Ecto.Changeset{changes: changes} = cs, field) do
    changes
    |> Map.get(field)
    |> String.to_charlist()
    |> case do
      [] ->
        false

      value ->
        value
        |> hd()
        |> Kernel.in(0..127)
    end
    |> if do
      cs
    else
      Ecto.Changeset.add_error(cs, field, "must be a valid ASCII character")
    end
  end

  @spec _validate_one_exists(Ecto.Changeset.t(), [atom()]) :: Ecto.Changeset.t()
  defp _validate_one_exists(%Ecto.Changeset{valid?: false} = cs, _fields), do: cs

  defp _validate_one_exists(%Ecto.Changeset{changes: changes} = cs, fields) do
    fields
    |> Enum.any?(fn field -> Map.has_key?(changes, field) end)
    |> if do
      cs
    else
      Ecto.Changeset.add_error(
        cs,
        hd(fields),
        "one of either these fields must be present: #{inspect(fields)}"
      )
    end
  end
end
