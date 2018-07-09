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
  # TODO: research about recv_timeout
  @options [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 50000]

  def credentials_yaml do
    [config | _] = :yamerl_constr.file("#{@root_dir}/config/jenkins_credentials.yml")
    username = :proplists.get_value('username', config) |> List.to_string()
    password = :proplists.get_value('password', config) |> List.to_string()
    [:ok, username, password]
  end

  defp jenkins_url_yaml do
    [config | _] = :yamerl_constr.file("#{@root_dir}/config/jenkins_credentials.yml")
    jenkins_url = :proplists.get_value('jenkins_url', config) |> List.to_string()
    [jenkins_url]
  end

  defp jenkins_jobs_yaml do
    [config | _] = :yamerl_constr.file("#{@root_dir}/config/jenkins_jobs.yml")
    :proplists.get_value('jenkins_jobs', config)
  end

  #
  # build/jobs ops
  #

  def all_builds_numbers_jobs do
    Enum.each(jenkins_jobs_yaml(), fn job ->
      all_builds_numbers_job(job)
    end)
  end

  defp all_builds_numbers_job(job_name) do
    headers = set_headers_with_credentials()
    url = "#{jenkins_url_yaml()}/job/#{job_name}/api/json"
    IO.puts(url)
    IO.puts("====")
    ## TODO: think to refactor this clause with the duplicata one
    case HTTPoison.get(url, headers, @options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        # TODO: extract in body the status and the testname
        IO.inspect(body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  defp set_headers_with_credentials do
    [:ok, user, pwd] = credentials_yaml()
    [Authorization: "#{user} #{pwd}", Accept: "Application/json; Charset=utf-8"]
  end

  # this is only for 1 build
  def build_results_raw do
    headers = set_headers_with_credentials()
    # TODO: remove the hardcoded number and job
    build_n = "3101"
    job_name = "manager-3.1-cucumber"

    url = "#{jenkins_url_yaml()}/job/#{job_name}/#{build_n}/testReport/api/json"

    case HTTPoison.get(url, headers, @options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        # TODO: extract in body the status and the testname
        IO.puts(body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end
end
