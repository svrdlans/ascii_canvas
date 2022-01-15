defmodule AC.WebApi.Canvas do
  @moduledoc """
  Represents a canvas with its properties.

  `content` is initialized as a map of columns where
  the value of each column is a row.
  For example calling `Canvas.create(4, 2)` will create
  the following canvas:

      %AC.WebApi.Canvas{
        content: %{
          0 => %{0 => nil, 1 => nil, 2 => nil, 3 => nil},
          1 => %{0 => nil, 1 => nil, 2 => nil, 3 => nil}
        },
        height: 2,
        id: "9080a794-2413-48ad-b4aa-5d1ac3aa93f6",
        width: 4
      }

  So when accessing canvas content, for example using coordinates `[3, 0]`,
  meaning `x` is 3 and `y` is 0, you should do it by inverting them:

      > %{canvas | content: put_in(canvas.content, [0, 3], "X")}
      %AC.WebApi.Canvas{
        content: %{
          0 => %{0 => nil, 1 => nil, 2 => nil, 3 => "X"},
          1 => %{0 => nil, 1 => nil, 2 => nil, 3 => nil}
        },
        height: 2,
        id: "9080a794-2413-48ad-b4aa-5d1ac3aa93f6",
        width: 4
      }

  This was done so that the map representation itself is easier to understand.
  """

  import AC.WebApi.Helpers.Guards

  @enforce_keys ~w(id width height)a
  defstruct [:content | @enforce_keys]

  @type uuid() :: <<_::288>>

  @type content() :: %{non_neg_integer => %{non_neg_integer => nil | String.t()}}

  @type id_fun() :: (() -> uuid())

  @type t() :: %__MODULE__{
          id: uuid(),
          content: content(),
          width: pos_integer(),
          height: pos_integer()
        }

  @spec create(width :: pos_integer(), height :: pos_integer(), id_fun :: id_fun()) :: t()
  def create(width, height, id_fun \\ &_get_id/0)
      when is_pos_integer(width) and is_pos_integer(height) do
    map = %{
      id: id_fun.(),
      content: _initialize_content(width, height),
      width: width,
      height: height
    }

    struct!(__MODULE__, map)
  end

  @spec to_string(t()) :: String.t()
  def to_string(%__MODULE__{content: content}) do
    content
    |> Enum.to_list()
    |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))
    |> Enum.reduce([], fn {_, line_map}, lines ->
      line =
        line_map
        |> Enum.to_list()
        |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))
        |> Enum.reduce([], fn {_, col_value}, acc ->
          [col_value || " " | acc]
        end)
        |> Enum.reverse()
        |> Enum.join()

      [line | lines]
    end)
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  @spec _get_id() :: uuid()
  defp _get_id, do: UUID.uuid4()

  @spec _initialize_content(width :: pos_integer(), height :: pos_integer()) :: content()
  defp _initialize_content(width, height) do
    0..(height - 1)
    |> Enum.reduce([], fn y_val, acc ->
      row =
        0..(width - 1)
        |> Enum.reduce([], fn x_val, acc ->
          pair = {x_val, nil}
          [pair | acc]
        end)
        |> Enum.reverse()
        |> Enum.into(%{})

      [{y_val, row} | acc]
    end)
    |> Enum.reverse()
    |> Enum.into(%{})
  end
end
