defmodule Kubeojo.Yaml do
  @root_dir File.cwd!()
  def credentials do
    [config | _] = :yamerl_constr.file("#{@root_dir}/config/jenkins_credentials.yml")
    username = :proplists.get_value('username', config) |> List.to_string()
    password = :proplists.get_value('password', config) |> List.to_string()
    [:ok, username, password]
  end

  def jenkins_url do
    [config | _] = :yamerl_constr.file("#{@root_dir}/config/jenkins_credentials.yml")
    :proplists.get_value('jenkins_url', config) |> List.to_string()
  end

  def jenkins_jobs do
    [config | _] = :yamerl_constr.file("#{@root_dir}/config/jenkins_jobs.yml")
    :proplists.get_value('jenkins_jobs', config)
  end
end
