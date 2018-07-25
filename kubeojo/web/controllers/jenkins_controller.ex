defmodule Kubeojo.JenkinsController do
  use Kubeojo.Web, :controller

  def index(conn, _params) do
    # get jobnames
    jobnames = Kubeojo.Yaml.jenkins_jobs()
    render conn, "index.html", jenkins: jobnames
  end
  
  def show(conn, %{"jobname" => jobname}) do
    failures_name_and_number = Kubeojo.Jenkins.Analyze.testfailures_pro_jobname(jobname)
    render conn, "show.html", failures: failures_name_and_number, jobname: jobname
  end
end
