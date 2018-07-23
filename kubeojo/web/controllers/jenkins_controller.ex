defmodule Kubeojo.JenkinsController do
  use Kubeojo.Web, :controller

  def index(conn, _params) do
    # get jobnames
    jenkins = ["job00", "foobar", "cucumber"] 
    render conn, "index.html", jenkins: jenkins
  end
  
  def show(conn, jobname) do
    #  jobs = Repo.all(Kubeojo.Testsfailures)
    render conn, "show.html", jobs: jobname
  end
end
