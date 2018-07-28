defmodule Kubeojo.Jenkins do
  require HTTPoison
  import Ecto.Query

  @moduledoc """
  Kubeojo.Jenkins retrive tests-failures.
  """
  @options [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 500_000]
  # this write data to db, pro jobname and jobnumber
  def write_tests_failures_to_db do
    Enum.map(Kubeojo.Yaml.jenkins_jobs(), fn jobname ->
      all_builds_numbers_from_jobname(jobname) |> tests_failed_pro_jobname_to_db
    end)
  end

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
        build_timestamp: build_timestamp,
        jobname: "#{job_name}",
        jobnumber: number
      })
    end)
  end

  defp jobname_database(false, failed_testnames, build_timestamp, job_name, number) do
    insert_new_tests_failures(failed_testnames, build_timestamp, job_name, number)
  end

  # jobname is in database
  defp jobname_database(true, failed_testnames, build_timestamp, job_name, job_number) do
    db_timestamps = Kubeojo.Repo.all(from(t in Kubeojo.TestsFailures, select: t.build_timestamp))
    db_jobname = Kubeojo.Repo.all(from(t in Kubeojo.TestsFailures, select: t.jobname))
    db_jobnumber = Kubeojo.Repo.all(from(t in Kubeojo.TestsFailures, select: t.jobnumber))

    # check if we have already results stored
    check_job_number_build_timestamp = fn
      {_, true, true, true} ->
        IO.puts("testname already present")

      {testnames, false, false, false} ->
        insert_new_tests_failures(testnames, build_timestamp, job_name, job_number)

      {testnames, false, false, true} ->
        insert_new_tests_failures(testnames, build_timestamp, job_name, job_number)

      {testnames, false, true, true} ->
        insert_new_tests_failures(testnames, build_timestamp, job_name, job_number)

      {_, _, _, _, _} ->
        IO.puts("unhandled case atm :)")
    end

    check_job_number_build_timestamp.({
      failed_testnames,
      build_timestamp in db_timestamps,
      job_number in db_jobnumber,
      to_string(job_name) in db_jobname
    })
  end

  # return %{jobnumber: number, testsname: failed_testname}
  defp tests_failed_pro_jobname_to_db(job) do
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
              |> Kubeojo.Jenkins.JunitParser.name_and_status()
              |> Kubeojo.Jenkins.JunitParser.failed_only()

            jobnames_db = Kubeojo.Repo.all(from(t in Kubeojo.TestsFailures, select: t.jobname))
            # write or not data to db
            Task.start(fn ->
              jobname_database(
                to_string(job.name) in jobnames_db,
                failed_testnames,
                build_timestamp,
                job.name,
                number
              )
            end)

          {:ok, %HTTPoison.Response{status_code: 404}} ->
            IO.puts("-> testsrusults notfound--> skipping")
        end
      end)

    # the clause 404 is adding :ok in map
    tests_failed |> Enum.reject(fn t -> t == :ok end)
  end
end
