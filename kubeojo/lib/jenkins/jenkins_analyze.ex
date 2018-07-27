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

    Enum.map(data, fn j ->
      count = Enum.count(data, fn n -> n.testname == j.testname end)
      %{j.testname => count}
    end)
  end
end
