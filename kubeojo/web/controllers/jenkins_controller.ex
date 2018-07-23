defmodule Kubeojo.JenkinsController do
  use Kubeojo.Web, :controller

  def index(conn, _params) do
    # get jobnames
    jobnames = Kubeojo.Yaml.jenkins_jobs()
    render conn, "index.html", jenkins: jobnames
  end
  
  def show(conn, jobname) do
    render conn, "show.html", jobs: jobname
  end
end
