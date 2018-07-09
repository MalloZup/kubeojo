defmodule Kubeojo.Jenkins do
  require HTTPoison
  @moduledoc """
  Documentation for Kubeojo.
  """
  @doc """
  get credentials jenkins from yaml file

  ## Examples

      iex> Kubeojo.get_credentials
     [:ok, "https://ci.suse.de/", "test", "secret"]

  """
  # jenkins specific:
  # 
  # we need to consider failed and regression as valid states for counting.
  # 
  # FAILED
  # This test failed, just like its previous run.
  # REGRESSION
  # This test has been running OK, but now it failed.
  #
  @root_dir File.cwd!

  def get_credentials_yaml do
    [config | _ ]  = :yamerl_constr.file("#{@root_dir}/config/jenkins_credentials.yml")
    jenkins_url = :proplists.get_value('jenkins_url', config) |> List.to_string
    username = :proplists.get_value('username', config) |> List.to_string
    password = :proplists.get_value('password', config) |> List.to_string
    [:ok, jenkins_url, username, password]
  end

  def get_jenkins_jobs_yaml do
    [config | _ ]  = :yamerl_constr.file("#{@root_dir}/config/jenkins_jobs.yml")
  end

  @doc """
  get all builds numbers stored given a jobname in jenkins
  """
  def get_all_builds_numbers_per_job do
    IO.puts "notyet"
  end

  defp build_results_raw do
    [:ok, jenkins_url, user, pwd]  = get_credentials_yaml()
    headers = ["Authorization": "#{user} #{pwd}", "Accept": "Application/json; Charset=utf-8"]
    # TODO: remove the hardcoded number and job
    build_n = "3101"
    job_name = "manager-3.1-cucumber"

    url = "#{jenkins_url}/job/#{job_name}/#{build_n}/testReport/api/json"
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 50000]
    case HTTPoison.get(url, headers, options) do
     {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
       # TODO: extract in body the status and the testname
       IO.puts body
     {:ok, %HTTPoison.Response{status_code: 404}} ->
       IO.puts "Not found :("
     {:error, %HTTPoison.Error{reason: reason}} ->
       IO.inspect reason
    end
  end

end
