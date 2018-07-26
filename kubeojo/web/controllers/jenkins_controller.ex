defmodule Kubeojo.JenkinsController do
  use Kubeojo.Web, :controller
   @root_dir File.cwd!()

  def index(conn, _params) do
    # get jobnames
    jobnames = Kubeojo.Yaml.jenkins_jobs()
    render conn, "index.html", jenkins: jobnames
  end
  
  def show(conn, %{"jobname" => jobname}) do
    failures_name_and_number = Kubeojo.Jenkins.Analyze.testfailures_pro_jobname(jobname)
    data = %{name: jobname, children: failures_name_and_number}
    IO.inspect(failures_name_and_number)
    File.write("#{@root_dir}/priv/static/js/flare2.json", Poison.encode!(data), [:binary])
    render conn, "show.html", failures: failures_name_and_number, jobname: jobname
  end
end
