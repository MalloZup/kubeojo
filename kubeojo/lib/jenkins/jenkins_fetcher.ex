defmodule Kubeojo.Jenkins do
  require HTTPoison

  @moduledoc """
  Kubeojo.Jenkins retrive tests-failures.
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
  @root_dir File.cwd!()
  @options [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 5000]

  def credentials_yaml do
    [config | _] = :yamerl_constr.file("#{@root_dir}/config/jenkins_credentials.yml")
    username = :proplists.get_value('username', config) |> List.to_string()
    password = :proplists.get_value('password', config) |> List.to_string()
    [:ok, username, password]
  end

  defp jenkins_url_yaml do
    [config | _] = :yamerl_constr.file("#{@root_dir}/config/jenkins_credentials.yml")
    :proplists.get_value('jenkins_url', config) |> List.to_string()
  end

  defp jenkins_jobs_yaml do
    [config | _] = :yamerl_constr.file("#{@root_dir}/config/jenkins_jobs.yml")
    :proplists.get_value('jenkins_jobs', config)
  end

  #
  # build/jobs ops
  #

  def all_builds_numbers_jobs do
    Enum.each(jenkins_jobs_yaml(), fn jobname ->
      all_builds_numbers_from_jobname(jobname) 
      |> build_results_raw
      |> Poison.decode!
      |> IO.inspect
    end)
  end

  defp all_builds_numbers_from_jobname(job_name) do
    headers = set_headers_with_credentials()
    url = "#{jenkins_url_yaml()}/job/#{job_name}/api/json"
    case HTTPoison.get(url, headers, @options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body_dec = body |> Poison.decode!
        builds = get_in(body_dec,  ["builds"]) 
        # manager-31-jenkins, [20, 304, 404] # jobname builds_number
        %{name: job_name, numbers: Enum.map(builds, fn (x) -> x["number"] end)}
    end
  end

  defp set_headers_with_credentials do
    [:ok, user, pwd] = credentials_yaml()
    [Authorization: "#{user} #{pwd}", Accept: "Application/json; Charset=utf-8"]
  end

  # this is only for 1 build
  def build_results_raw(job) do
    headers = set_headers_with_credentials()
    Enum.each(job.numbers, fn number -> 
      url = "#{jenkins_url_yaml()}/job/#{job.name}/#{number}/testReport/api/json"
      case HTTPoison.get(url, headers, @options) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          body |> Poison.decode! |> IO.inspect
      end
      # TODO: skip if build is currently running no results
      case 
    end)
  end
end
