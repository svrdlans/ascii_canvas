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
          coords: [non_neg_integer()],
          width: pos_integer(),
          height: pos_integer(),
          borders: [non_neg_integer()]
        }

  @impl Canvas.DrawingBehaviour
  @spec rectangle(canvas :: Canvas.t(), params :: Canvas.DrawingBehaviour.params()) :: Canvas.t()
  def rectangle(canvas, params) do
    params = add_borders(params)

    params
    |> get_coords_to_fill()
    |> fill_coords(canvas, params)
  end

  @spec add_borders(params :: Canvas.DrawingBehaviour.params()) :: fill_params()
  def add_borders(%{coords: [x, y], width: width, height: height} = params) do
    params
    |> Map.put(:borders, [x + width - 1, y + height - 1])
  end

  @spec fill_coords(coords :: [[non_neg_integer]], canvas :: Canvas.t(), params :: fill_params()) ::
          Canvas.t()
  def fill_coords([], canvas, _params), do: canvas

  def fill_coords([[_, _] = pair | rest], %{content: content} = canvas, params) do
    char = get_fill_char(pair, params)
    canvas = %{canvas | content: put_in(content, pair, char)}
    fill_coords(rest, canvas, params)
  end

  @spec get_coords_to_fill(params :: fill_params()) :: [[non_neg_integer()]]
  def get_coords_to_fill(%{coords: [x, y], borders: [border_x, border_y]}),
    do: for(x_val <- x..border_x, y_val <- y..border_y, do: [x_val, y_val])

  @spec get_fill_char(coord :: [non_neg_integer()], params :: fill_params()) :: char()
  def get_fill_char([x_val, y_val], %{
        coords: [x, y],
        borders: [border_x, border_y],
        outline: outline
      })
      when x_val in [x, border_x] or y_val in [y, border_y],
      do: outline

  def get_fill_char(_, %{fill: fill}), do: fill
end