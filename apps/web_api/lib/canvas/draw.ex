defmodule AC.WebApi.Canvas.Draw do
  @moduledoc """
  Contains drawing operations that can be executed on a canvas.
  """

  alias AC.WebApi.Canvas
  @behaviour Canvas.DrawingBehaviour

  @type fill_params() :: %{
          optional(:outline) => String.t(),
          optional(:fill) => String.t(),
          id: Canvas.uuid(),
          upper_left_corner: [non_neg_integer()],
          width: pos_integer(),
          height: pos_integer(),
          borders: [non_neg_integer()]
        }

  @impl Canvas.DrawingBehaviour
  @spec rectangle(canvas :: Canvas.t(), params :: Canvas.DrawingBehaviour.params()) :: Canvas.t()
  def rectangle(%Canvas{} = canvas, params) do
    params = add_borders(params)

    params
    |> get_coords_to_fill()
    |> fill_coords(canvas, params)
  end

  @impl Canvas.DrawingBehaviour
  @spec flood_fill(canvas :: Canvas.t(), params :: Canvas.DrawingBehaviour.fill_params()) ::
          Canvas.t()
  def flood_fill(%Canvas{} = canvas, _params) do
    canvas
  end

  @spec add_borders(params :: Canvas.DrawingBehaviour.params()) :: fill_params()
  def add_borders(%{upper_left_corner: [x, y], width: width, height: height} = params) do
    params
    |> Map.put(:borders, [x + width - 1, y + height - 1])
  end

  @spec fill_coords(coords :: [[non_neg_integer]], canvas :: Canvas.t(), params :: fill_params()) ::
          Canvas.t()
  def fill_coords([], canvas, _params), do: canvas

  def fill_coords([[x, y] = pair | rest], %{content: content} = canvas, params) do
    char = get_fill_char(pair, params)
    # x and y are reversed because of the way the canvas is initialized
    canvas = %{canvas | content: put_in(content, [y, x], char)}
    fill_coords(rest, canvas, params)
  end

  @spec get_coords_to_fill(params :: fill_params()) :: [[non_neg_integer()]]
  def get_coords_to_fill(%{upper_left_corner: [x, y], borders: [border_x, border_y]}),
    do: for(x_val <- x..border_x, y_val <- y..border_y, do: [x_val, y_val])

  @spec get_fill_char(coord :: [non_neg_integer()], params :: fill_params()) :: char()
  def get_fill_char([x_val, y_val], %{
        upper_left_corner: [x, y],
        borders: [border_x, border_y],
        outline: outline,
        fill: fill
      })
      when x_val in [x, border_x] or y_val in [y, border_y],
      do: outline || fill

  def get_fill_char(_, %{fill: fill}), do: fill
end
