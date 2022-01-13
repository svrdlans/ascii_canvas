defmodule AC.WebApi.Canvas do
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

  @spec _get_id() :: uuid()
  defp _get_id, do: UUID.uuid4()

  @spec _initialize_content(width :: pos_integer(), height :: pos_integer()) :: content()
  defp _initialize_content(width, height) do
    0..(width - 1)
    |> Enum.reduce([], fn x_val, acc ->
      row =
        0..(height - 1)
        |> Enum.reduce([], fn y_val, acc ->
          pair = {y_val, nil}
          [pair | acc]
        end)
        |> Enum.into(%{})

      [{x_val, row} | acc]
    end)
    |> Enum.into(%{})
  end
end
