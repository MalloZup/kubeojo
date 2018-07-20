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


defmodule Kubeojo.Jenkins do
  require HTTPoison
  import Ecto.Query

  @moduledoc """
  Kubeojo.Jenkins retrive tests-failures.
  """
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

  @options [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 500_000]
  def all_retrieve_map_failure_and_testsname do
    Enum.map(Kubeojo.Yaml.jenkins_jobs(), fn jobname ->
      all_builds_numbers_from_jobname(jobname) |> tests_failed_pro_jobname
    end)
  end

  # from yaml builds return filtered map:
  # %{jobname, [job_numbers]}
  # manager-31-jenkins, [20, 304, 404] # jobname builds_number
  defp all_builds_numbers_from_jobname(job_name) do
    url = "#{Kubeojo.Yaml.jenkins_url()}/job/#{job_name}/api/json"
    headers = set_headers_with_credentials()

    case HTTPoison.get(url, headers, @options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        builds = body |> Poison.decode!() |> get_in(["builds"])
        %{name: job_name, numbers: Enum.map(builds, fn x -> x["number"] end)}
    end
  end

  defp set_headers_with_credentials do
    [:ok, user, pwd] = Kubeojo.Yaml.credentials()
    [Authorization: "#{user} #{pwd}", Accept: "Application/json; Charset=utf-8"]
  end

  defp jobname_timestamp(job_name, number) do
    url = "#{Kubeojo.Yaml.jenkins_url()}/job/#{job_name}/#{number}/api/json?tree=timestamp"
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

  # write data to db
  defp insert_new_tests_failures(failed_testnames, build_timestamp, job_name, number) do
    Enum.each(failed_testnames, fn failed_testname ->
      Kubeojo.Repo.insert(%Kubeojo.TestsFailures{
        testname: failed_testname,
        count_failed: 1,
        build_timestamp: build_timestamp,
        jobname: "#{job_name}",
        jobnumber: number
      })
    end)
  end

  defp update_tests_failures(_failed_testnames, _count) do
    # get and incremnt count of failures
  end

  defp jobname_database(false, failed_testnames, build_timestamp, job_name, number) do
    insert_new_tests_failures(failed_testnames, build_timestamp, job_name, number)
  end
  # jobname is in database
  defp jobname_database(true, _failed_testnames, build_timestamp, job_name, job_number) do
    results =
      Kubeojo.Repo.all(
        from(
          t in Kubeojo.TestsFailures,
          select: [t.testname, t.build_timestamp, t.jobnumber, t.jobname, t.count_failed]
        )
      )

    IO.inspect(results)
    # check if we have already results stored
    check_job_number_build_timestamp = fn
      # here data is duplicata -> skip
      {testnames, true, true, true, _} -> IO.inspect(testnames)

      {testnames, false, false, false, _} -> insert_new_tests_failures(testnames, build_timestamp, job_name, job_number)

      {testnames, false, false, true, _} ->  insert_new_tests_failures(testnames, build_timestamp, job_name, job_number)

      {testnames, false, true, true, count} ->   update_tests_failures(testnames, count)

      {_, _, _, _, _} ->

        IO.puts("unhandled case atm :)")
    end

    check_job_number_build_timestamp.(
      results[0],
      #  to_string(build_timestamp) in results[1],
      to_string(job_number) in results[2],
      to_string(job_name) in results[3],
      results[4]
    )
  end

  # return %{jobnumber: number, testsname: failed_testname}
  defp tests_failed_pro_jobname(job) do
    headers = set_headers_with_credentials()

    tests_failed =
      Enum.map(job.numbers, fn number ->
        url = "#{Kubeojo.Yaml.jenkins_url()}/job/#{job.name}/#{number}/testReport/api/json"
        build_timestamp = jobname_timestamp(job.name, number)

        case HTTPoison.get(url, headers, @options) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            failed_testnames =
              body
              |> Poison.decode!()
              |> JunitParser.name_and_status()
              |> JunitParser.failed_only()

            jobnames_db =
              Kubeojo.Repo.all(
                from(t in Kubeojo.TestsFailures, select: t.jobname )
              )

            Task.start(fn -> jobname_database(to_string(job.name) in jobnames_db, failed_testnames, build_timestamp, job.name, number) end)

          {:ok, %HTTPoison.Response{status_code: 404}} ->
            IO.puts("-> testsrusults notfound--> skipping")
        end
      end)

    # the clause 404 is adding :ok in map
    tests_failed |> Enum.reject(fn t -> t == :ok end)
  end
end
