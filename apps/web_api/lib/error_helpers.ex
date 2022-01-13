defmodule AC.WebApi.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  @not_found "not found"
  @id_not_found {:id, {@not_found, []}}

  @doc """
  Translates an error message.
  """
  def translate_error({msg, opts}) do
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  @spec id_not_found?(keyword()) :: boolean()
  def id_not_found?(errors) when is_list(errors) do
    errors
    |> Enum.any?(fn
      @id_not_found -> true
      _ -> false
    end)
  end
end
