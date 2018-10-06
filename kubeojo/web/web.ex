defmodule Kubeojo.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Kubeojo.Web, :controller
      use Kubeojo.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  @spec model() :: {:__block__, [], [{:import, [...], [...]} | {:use, [...], [...]}, ...]}
  def model do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
    end
  end

  @spec controller() ::
          {:__block__, [],
           [{:alias, [...], [...]} | {:import, [...], [...]} | {:use, [...], [...]}, ...]}
  def controller do
    quote do
      use Phoenix.Controller

      alias Kubeojo.Repo
      import Ecto
      import Ecto.Query

      import Kubeojo.Router.Helpers
      import Kubeojo.Gettext
    end
  end

  @spec view() :: {:__block__, [], [{:import, [...], [...]} | {:use, [...], [...]}, ...]}
  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Kubeojo.Router.Helpers
      import Kubeojo.ErrorHelpers
      import Kubeojo.Gettext
    end
  end

  @spec router() ::
          {:use, [{:context, Kubeojo.Web} | {:import, Kernel}, ...],
           [{:__aliases__, [...], [...]}, ...]}
  def router do
    quote do
      use Phoenix.Router
    end
  end

  @spec channel() ::
          {:__block__, [],
           [{:alias, [...], [...]} | {:import, [...], [...]} | {:use, [...], [...]}, ...]}
  def channel do
    quote do
      use Phoenix.Channel

      alias Kubeojo.Repo
      import Ecto
      import Ecto.Query
      import Kubeojo.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
