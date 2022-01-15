defmodule AC.WebApi.Canvas.DrawingBehaviour do
  alias AC.WebApi.Canvas

  @type params() :: %{
          optional(:outline) => String.t(),
          optional(:fill) => String.t(),
          id: Canvas.uuid(),
          upper_left_corner: [non_neg_integer()],
          width: pos_integer(),
          height: pos_integer()
        }

  @callback rectangle(canvas :: Canvas.t(), params :: params()) :: Canvas.t()
end
