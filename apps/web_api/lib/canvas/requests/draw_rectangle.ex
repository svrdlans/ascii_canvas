defmodule AC.WebApi.Canvas.Requests.DrawRectangle do
  @moduledoc """
  Used to validate a request to draw a rectangle.
  """

  alias AC.WebApi.Canvas
  alias AC.WebApi.Repo

  use Ecto.Schema

  @type t() :: %__MODULE__{
          id: Canvas.uuid(),
          upper_left_corner: [non_neg_integer()],
          width: pos_integer(),
          height: pos_integer(),
          outline: String.t(),
          fill: String.t()
        }

  @primary_key false
  embedded_schema do
    field :id, Ecto.UUID
    field :upper_left_corner, {:array, :integer}
    field :width, :integer
    field :height, :integer
    field :outline, :string
    field :fill, :string
  end

  @not_found "not found"

  @spec validate(params :: map(), repo :: module()) :: Ecto.Changeset.t()
  def validate(params, repo) when is_atom(repo) do
    required_fields = ~w(id upper_left_corner width height)a
    optional_fields = ~w(outline fill)a

    %__MODULE__{}
    |> Ecto.Changeset.cast(params, required_fields ++ optional_fields)
    |> Ecto.Changeset.validate_required(required_fields)
    |> _validate_id_exists(repo)
    |> Ecto.Changeset.validate_length(:upper_left_corner, is: 2)
    |> _validate_boundaries()
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

  @spec _validate_id_exists(Ecto.Changeset.t(), module()) :: Ecto.Changeset.t()
  defp _validate_id_exists(%Ecto.Changeset{valid?: false} = cs, _),
    do: cs

  defp _validate_id_exists(%Ecto.Changeset{changes: %{id: id}, params: params} = cs, repo) do
    case Repo.get(repo, id) do
      nil ->
        Ecto.Changeset.add_error(cs, :id, @not_found)

      %{width: width, height: height} ->
        %{
          cs
          | params:
              params
              |> Map.merge(%{"__canvas_width" => width, "__canvas_height" => height})
        }
    end
  end

  @spec _validate_boundaries(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp _validate_boundaries(%Ecto.Changeset{valid?: false} = cs), do: cs

  defp _validate_boundaries(
         %Ecto.Changeset{
           changes: %{upper_left_corner: [x, y]},
           params: %{"__canvas_width" => canvas_width, "__canvas_height" => canvas_height}
         } = cs
       ) do
    max_x = canvas_width - 1
    max_y = canvas_height - 1

    case {{:x, x >= 0 and x <= max_x}, {:y, y >= 0 and y <= max_y}} do
      {{:x, true}, {:y, true}} ->
        cs

      {{:x, false}, {:y, true}} ->
        Ecto.Changeset.add_error(
          cs,
          :upper_left_corner,
          "out of bounds: x must be between 0 and %{max_x}",
          max_x: max_x
        )

      {{:x, true}, {:y, false}} ->
        Ecto.Changeset.add_error(
          cs,
          :upper_left_corner,
          "out of bounds: y must be between 0 and %{max_y}",
          max_y: max_y
        )

      {{:x, false}, {:y, false}} ->
        Ecto.Changeset.add_error(
          cs,
          :upper_left_corner,
          "out of bounds: x must be between 0 and %{max_x}, y between 0 and %{max_y}",
          max_x: max_x,
          max_y: max_y
        )
    end
  end

  @spec _validate_number(Ecto.Changeset.t(), atom()) :: Ecto.Changeset.t()
  defp _validate_number(%Ecto.Changeset{valid?: false} = cs, _field), do: cs

  defp _validate_number(
         %Ecto.Changeset{
           changes: %{upper_left_corner: [x, _]},
           params: %{"__canvas_width" => canvas_width}
         } = cs,
         :width
       ) do
    max_value = canvas_width - x
    Ecto.Changeset.validate_number(cs, :width, greater_than: 0, less_than_or_equal_to: max_value)
  end

  defp _validate_number(
         %Ecto.Changeset{
           changes: %{upper_left_corner: [_, y]},
           params: %{"__canvas_height" => canvas_height}
         } = cs,
         :height
       ) do
    max_value = canvas_height - y
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
    |> case do
      <<0::size(1), _::size(7)>> -> cs
      _ -> Ecto.Changeset.add_error(cs, field, "must be a valid ASCII character")
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
