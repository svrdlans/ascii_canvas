defmodule AC.WebApi do
  def controller do
    quote do
      use Phoenix.Controller, namespace: AC.WebApi

      import Plug.Conn
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
