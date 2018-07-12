defmodule Kubeojo.Jenkins do
  require HTTPoison

  @moduledoc """
  Kubeojo.Jenkins retrive tests-failures.
  """

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

  defmodule JunitParser do
    def name_and_status(%{"suites" => suites}) do
      status = get_in(suites, [Access.all(), "cases", Access.all(), "status"]) |> List.flatten
      name = get_in(suites, [Access.all(), "cases", Access.all(), "name"]) |> List.flatten
      Enum.zip(name, status) |> Enum.into(%{})
    end

    # get a map{name:status} only regression and failed tests.
    # this will be stored in db.
    #  when the list is empty testsuite was green or no-results. (ignore empty)
    def failed_only(name_and_status) do 
      handle_result = fn
        {test_name, "REGRESSION"} -> test_name
        {test_name, "FAILED"} -> test_name
        {_, _} -> nil 
      end
      Enum.map(name_and_status, handle_result) 
      |>  Enum.reject(fn(t) -> t == nil end)
    end
  end
  
  @options [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 5000]
  # This is the function which will retrive the testname and if failed
    def all_builds_numbers_jobs do
      Enum.each(Yaml.jenkins_jobs(), fn jobname ->
        IO.puts ("#{jobname}\n")
        all_builds_numbers_from_jobname(jobname)
        |> build_results_raw
      end)
    end

  # from yaml builds return filtered map:
  # %{jobname, [job_numbers]}
  # manager-31-jenkins, [20, 304, 404] # jobname builds_number
  defp all_builds_numbers_from_jobname(job_name) do
    headers = set_headers_with_credentials()
    url = "#{Yaml.jenkins_url()}/job/#{job_name}/api/json"

    case HTTPoison.get(url, headers, @options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body_dec = body |> Poison.decode!()
        builds = get_in(body_dec, ["builds"])
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

      IO.puts ("------------#{job.name}#{number}------------")
      case HTTPoison.get(url, headers, @options) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          # FIXME: REMOVE IO.inspect for debugging
          body |> Poison.decode!() |> JunitParser.name_and_status |> JunitParser.failed_only |> IO.inspect
        {:ok, %HTTPoison.Response{status_code: 404}} ->
          IO.puts("-> testsrusults notfound--> skipping")
      end
      IO.puts ("")
    end)
  end
end
