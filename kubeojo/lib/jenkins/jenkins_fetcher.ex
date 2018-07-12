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

  # yaml operations (read credentials)
  defmodule Yaml do
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

@options [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 5000]
 def all_builds_numbers_jobs do
      Enum.each(Yaml.jenkins_jobs(), fn jobname ->
        all_builds_numbers_from_jobname(jobname)
        |> build_results_raw
      end)
    end
  
  defp all_builds_numbers_from_jobname(job_name) do
    headers = set_headers_with_credentials()
    url = "#{Yaml.jenkins_url()}/job/#{job_name}/api/json"

    case HTTPoison.get(url, headers, @options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body_dec = body |> Poison.decode!()
        builds = get_in(body_dec, ["builds"])
        # manager-31-jenkins, [20, 304, 404] # jobname builds_number
        %{name: job_name, numbers: Enum.map(builds, fn x -> x["number"] end)}
    end
  end

  defp set_headers_with_credentials do
    [:ok, user, pwd] = Yaml.credentials()
    [Authorization: "#{user} #{pwd}", Accept: "Application/json; Charset=utf-8"]
  end

  defp build_results_raw(job) do
    headers = set_headers_with_credentials()

    Enum.each(job.numbers, fn number ->
      url = "#{Yaml.jenkins_url()}/job/#{job.name}/#{number}/testReport/api/json"

      case HTTPoison.get(url, headers, @options) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          body |> Poison.decode!() |> IO.inspect()

        {:ok, %HTTPoison.Response{status_code: 404}} ->
          IO.puts("-> testsrusults notfound--> skipping")
      end
    end)
  end
end
