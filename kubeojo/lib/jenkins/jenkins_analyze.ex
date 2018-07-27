# count failures and manipulate for statistics jenkins data
defmodule Kubeojo.Jenkins.Analyze do
  import Ecto.Query

  def count_all_testsfailures() do
    Enum.map(Kubeojo.Yaml.jenkins_jobs(), fn jobname ->
      {String.to_atom(to_string(jobname)), testfailures_pro_jobname(jobname)}
    end)
  end

  def testfailures_pro_jobname(jobname) do
    data =
      Kubeojo.Repo.all(
        from(
          t in Kubeojo.TestsFailures,
          where: t.jobname == ^to_string(jobname),
          select: %{timestamp: t.build_timestamp, jobnumber: t.jobnumber, testname: t.testname}
        )
      )

    duplicata_map =
      Enum.map(data, fn j ->
        count = Enum.count(data, fn n -> n.testname == j.testname end)
        %{j.testname => count}
      end)

    list_uniq_testnames =
      duplicata_map
      |> Enum.map(fn y -> Map.keys(y) end)
      |> Enum.uniq()

    # for the uniq_test_names get the uniq-count
    uniq_count =
      Enum.map(list_uniq_testnames, fn uname ->
        count =
          Enum.map(duplicata_map, fn dmap ->
            dmap[to_string(uname)]
          end)

        count |> Enum.reject(fn t -> t == nil end) |> Enum.uniq() |> List.flatten()
      end)

    Enum.zip(List.flatten(list_uniq_testnames), List.flatten(uniq_count)) |> Enum.into(%{})
  end
end
