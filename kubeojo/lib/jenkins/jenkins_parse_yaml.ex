defmodule Kubeojo.Yaml do
  @root_dir File.cwd!()
  @spec credentials() :: none()
  def credentials do
    [config | _] = :yamerl_constr.file("#{@root_dir}/config/jenkins_credentials.yml")
    username = :proplists.get_value('username', config) |> List.to_string()
    password = :proplists.get_value('password', config) |> List.to_string()
    [:ok, username, password]
  end

  @spec jenkins_url() :: none()
  def jenkins_url do
    [config | _] = :yamerl_constr.file("#{@root_dir}/config/jenkins_credentials.yml")
    :proplists.get_value('jenkins_url', config) |> List.to_string()
  end

  @spec jenkins_jobs() :: none()
  def jenkins_jobs do
    [config | _] = :yamerl_constr.file("#{@root_dir}/config/jenkins_jobs.yml")
    :proplists.get_value('jenkins_jobs', config)
  end
end
