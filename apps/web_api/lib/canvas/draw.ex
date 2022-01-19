defmodule AC.WebApi.Canvas.Draw do
  @moduledoc """
  Contains drawing operations that can be executed on a canvas.
  """

  alias AC.WebApi.Canvas
  @behaviour Canvas.DrawingBehaviour

  @type fill_char() :: <<_::8>>

  @type fill_params() :: %{
          :outline => nil | fill_char(),
          :fill => nil | fill_char(),
          id: Canvas.uuid(),
          upper_left_corner: [non_neg_integer()],
          width: pos_integer(),
          height: pos_integer(),
          borders: [non_neg_integer()]
        }

  @directions [up: [0, -1], right: [1, 0], down: [0, 1], left: [-1, 0]]

  @impl Canvas.DrawingBehaviour
  @spec rectangle(canvas :: Canvas.t(), params :: Canvas.DrawingBehaviour.rectangle_params()) ::
          Canvas.t()
  def rectangle(%Canvas{} = canvas, params) do
    params = _add_borders(params)

    params
    |> _get_coords_to_fill()
    |> _fill_coords(canvas, params)
  end

  @impl Canvas.DrawingBehaviour
  @spec flood_fill(canvas :: Canvas.t(), params :: Canvas.DrawingBehaviour.flood_params()) ::
          Canvas.t()
  def flood_fill(%Canvas{} = canvas, %{start_coordinates: [x, y], fill: fill}) do
    canvas
    |> _traverse_directions([x, y], fill)
  end

  @spec _add_borders(params :: Canvas.DrawingBehaviour.rectangle_params()) :: fill_params()
  defp _add_borders(%{upper_left_corner: [x, y], width: width, height: height} = params) do
    params
    |> Map.put(:borders, [x + width - 1, y + height - 1])
  end

  @spec _fill_coords(coords :: [[non_neg_integer]], canvas :: Canvas.t(), params :: fill_params()) ::
          Canvas.t()
  defp _fill_coords([], canvas, _params), do: canvas

  defp _fill_coords([[x, y] = pair | rest], %{content: content} = canvas, params) do
    char = _get_fill_char(pair, params)
    # x and y are reversed because of the way the canvas is initialized
    canvas = %{canvas | content: put_in(content, [y, x], char)}
    _fill_coords(rest, canvas, params)
  end

  @spec _get_coords_to_fill(params :: fill_params()) :: [[non_neg_integer()]]
  defp _get_coords_to_fill(%{upper_left_corner: [x, y], borders: [border_x, border_y]}),
    do: for(x_val <- x..border_x, y_val <- y..border_y, do: [x_val, y_val])

  @spec _get_fill_char(coord :: [non_neg_integer()], params :: fill_params()) :: fill_char()
  defp _get_fill_char([x_val, y_val], %{
         upper_left_corner: [x, y],
         borders: [border_x, border_y],
         outline: outline,
         fill: fill
       })
       when x_val in [x, border_x] or y_val in [y, border_y],
       do: outline || fill

  defp _get_fill_char(_, %{fill: fill}), do: fill

  @spec _traverse_directions(
          canvas :: Canvas.t(),
          point :: [non_neg_integer()],
          fill :: fill_char()
        ) :: Canvas.t()
  defp _traverse_directions(
         %Canvas{content: content} = canvas,
         [x, y] = point,
         fill
       ) do
    canvas = %{canvas | content: put_in(content, [y, x], fill)}

    @directions
    |> Enum.reduce(canvas, fn {_direction, point_modifier}, traversed ->
      next_point = point |> _get_next_point(point_modifier)

      next_point
      |> _is_valid_point?(traversed)
      |> if do
        _traverse_directions(traversed, next_point, fill)
      else
        traversed
      end
    end)
  end

  @spec _is_valid_point?([non_neg_integer], Canvas.t()) :: boolean()
  defp _is_valid_point?([x, y], %Canvas{content: content, width: width, height: height})
       when x >= 0 and x < width and y >= 0 and y < height,
       do: content |> get_in([y, x]) |> is_nil()

  defp _is_valid_point?(_, _), do: false

  @spec _get_next_point([non_neg_integer()], [non_neg_integer()]) :: [non_neg_integer()]
  defp _get_next_point([x, y], [mod_x, mod_y]),
    do: [x + mod_x, y + mod_y]
end
