defmodule AC.WebApi.Canvas.Requests.Show do
  @moduledoc """
  Used for validating canvas show request.
  Delegates calls to `AC.WebApi.Canvas.Requests.Delete` module.
  """

  alias AC.WebApi.Canvas.Requests.Delete

  defdelegate validate(params, repo), to: Delete
  defdelegate changes(cs), to: Delete
end
