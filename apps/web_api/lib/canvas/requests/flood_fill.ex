defmodule AC.WebApi.Canvas.Requests.FloodFill do
  @moduledoc """
  Used to validate a request to flood fill a rectangle.
  """

  alias AC.WebApi.Canvas

  use Ecto.Schema

  @type t() :: %__MODULE__{
          id: Canvas.uuid(),
          start_coordinates: [non_neg_integer()],
          fill: String.t()
        }

  @primary_key false
  embedded_schema do
    field :id, Ecto.UUID
    field :start_coordinates, {:array, :integer}
    field :fill, :string
  end

  @not_found "not found"

  @spec validate(params :: map(), repo :: module()) :: Ecto.Changeset.t()
  def validate(params, repo) when is_atom(repo) do
    required_fields = ~w(id start_coordinates fill)a

    %__MODULE__{}
    |> Ecto.Changeset.cast(params, required_fields)
    |> Ecto.Changeset.validate_required(required_fields)
    |> Ecto.Changeset.validate_length(:start_coordinates, is: 2)
    |> Ecto.Changeset.validate_length(:fill, is: 1)
    |> _validate_ascii(:fill)
    |> _validate_id_exists(repo)
    |> _validate_boundaries()
    |> _validate_availability()
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
    case repo.get(id) do
      nil ->
        Ecto.Changeset.add_error(cs, :id, @not_found)

      %{width: width, height: height, content: content} ->
        %{
          cs
          | params:
              params
              |> Map.merge(%{
                "__canvas_width" => width,
                "__canvas_height" => height,
                "__canvas_content" => content
              })
        }
    end
  end

  @spec _validate_boundaries(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp _validate_boundaries(%Ecto.Changeset{valid?: false} = cs), do: cs

  defp _validate_boundaries(
         %Ecto.Changeset{
           changes: %{start_coordinates: [x, y]},
           params: %{
             "__canvas_width" => canvas_width,
             "__canvas_height" => canvas_height
           }
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
          :start_coordinates,
          "out of bounds: x must be between 0 and %{max_x}",
          max_x: max_x
        )

      {{:x, true}, {:y, false}} ->
        Ecto.Changeset.add_error(
          cs,
          :start_coordinates,
          "out of bounds: y must be between 0 and %{max_y}",
          max_y: max_y
        )

      {{:x, false}, {:y, false}} ->
        Ecto.Changeset.add_error(
          cs,
          :start_coordinates,
          "out of bounds: x must be between 0 and %{max_x}, y between 0 and %{max_y}",
          max_x: max_x,
          max_y: max_y
        )
    end
  end

  @spec _validate_availability(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp _validate_availability(%Ecto.Changeset{valid?: false} = cs), do: cs

  defp _validate_availability(
         %Ecto.Changeset{
           changes: %{start_coordinates: [x, y]},
           params: %{"__canvas_content" => canvas_content}
         } = cs
       ) do
    canvas_content
    |> get_in([y, x])
    |> case do
      nil ->
        cs

      _ ->
        Ecto.Changeset.add_error(
          cs,
          :start_coordinates,
          "already filled"
        )
    end
  end

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
end
