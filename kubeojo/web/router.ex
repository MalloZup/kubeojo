defmodule Kubeojo.Router do
    #jenkins = Repo.all(Kubeojo.TestsFailures)
  use Kubeojo.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Kubeojo do
    pipe_through :browser # Use the default browser stack
    get "/", JenkinsController, :index
    get "/jenkins/:jobname", JenkinsController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", Kubeojo do
  #   pipe_through :api
  # end
end
