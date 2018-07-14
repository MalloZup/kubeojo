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
      status = get_in(suites, [Access.all(), "cases", Access.all(), "status"]) |> List.flatten()
      name = get_in(suites, [Access.all(), "cases", Access.all(), "name"]) |> List.flatten()
      Enum.zip(name, status) |> Enum.into(%{})
    end

    # from results filter and keep only failed tests 
    def failed_only(testname_and_status) do
      handle_result = fn
        {test_name, "REGRESSION"} -> test_name
        {test_name, "FAILED"} -> test_name
        {_, _} -> nil
      end

      Enum.map(testname_and_status, handle_result)
      |> Enum.reject(fn t -> t == nil end)
    end
  end

  @options [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 5000]
  def all_retrieve_map_failure_and_testsname do
      Enum.map(Yaml.jenkins_jobs(), fn jobname ->
        build_number_andtest =
          all_builds_numbers_from_jobname(jobname) |> tests_failed_pro_jobname

        %{jobname: jobname, failures: build_number_andtest}
      end)
  end

  # from yaml builds return filtered map:
  # %{jobname, [job_numbers]}
  # manager-31-jenkins, [20, 304, 404] # jobname builds_number
  defp all_builds_numbers_from_jobname(job_name) do
    url = "#{Yaml.jenkins_url()}/job/#{job_name}/api/json"
    headers = set_headers_with_credentials()

    case HTTPoison.get(url, headers, @options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        builds = body |> Poison.decode!() |> get_in(["builds"])
        %{name: job_name, numbers: Enum.map(builds, fn x -> x["number"] end)}
    end
  end

  defp set_headers_with_credentials do
    [:ok, user, pwd] = Yaml.credentials()
    [Authorization: "#{user} #{pwd}", Accept: "Application/json; Charset=utf-8"]
  end

  defp jobname_timestamp(job_name, number) do
    url = "#{Yaml.jenkins_url()}/job/#{job_name}/#{number}/api/json?tree=timestamp"
    headers = set_headers_with_credentials()
    build_timestamp =
      case HTTPoison.get(url, headers, @options) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          %{"timestamp" => timestamp} = body |> Poison.decode!()
          timestamp

        {:ok, %HTTPoison.Response{status_code: 404}} ->
          IO.puts("-> testsrusults notfound--> skipping")
      end

    build_timestamp
  end

  # return %{jobnumber: number, testsname: failed_testname}
  defp tests_failed_pro_jobname(job) do
    headers = set_headers_with_credentials()

    tests_failed =
      Enum.map(job.numbers, fn number ->
        url = "#{Yaml.jenkins_url()}/job/#{job.name}/#{number}/testReport/api/json"
        build_timestamp = jobname_timestamp(job.name, number)

        case HTTPoison.get(url, headers, @options) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            failed_testname =
              body
              |> Poison.decode!()
              |> JunitParser.name_and_status()
              |> JunitParser.failed_only()

            %{jobnumber: number, testsname: failed_testname, build_timestamp: build_timestamp}

          {:ok, %HTTPoison.Response{status_code: 404}} ->
            IO.puts("-> testsrusults notfound--> skipping")
        end
      end)

    # the clause 404 is adding :ok in map
    tests_failed |> Enum.reject(fn t -> t == :ok end)
  end

  defp AllFailures do
    jenk_data = all_retrieve_map_failure_and_testsname()
    Enum.map(jenk_data, fn jobs ->
      get_in(jobs, [:failures, Access.all(), :testsname])
    end)
  end
end
