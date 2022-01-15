defmodule AC.WebApi.Canvas.DrawingBehaviour do
  alias AC.WebApi.Canvas

  @type ascii_char() :: <<_::8>>

  @type params() :: %{
          optional(:outline) => String.t(),
          optional(:fill) => String.t(),
          id: Canvas.uuid(),
          upper_left_corner: [non_neg_integer()],
          width: pos_integer(),
          height: pos_integer()
        }

  @type fill_params() :: %{
          id: Canvas.uuid(),
          start_coordinates: [non_neg_integer()],
          fill: ascii_char()
        }

  @callback rectangle(canvas :: Canvas.t(), params :: params()) :: Canvas.t()

  @callback flood_fill(canvas :: Canvas.t(), params :: fill_params()) :: Canvas.t()
end
