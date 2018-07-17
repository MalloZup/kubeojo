# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Kubeojo.Repo.insert!(%Kubeojo.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
#
alias Kubeojo.TestsFailures
alias Kubeojo.Repo
import Ecto.Query
jenk_data =  Kubeojo.Jenkins.all_retrieve_map_failure_and_testsname

# Send the query to the repository

Enum.each(jenk_data, fn(jobs) ->
  query = from j in "tests_failures",
           where: like(j.jobname,^jobs.jobname),
           select: j.jobname
  IO.puts Repo.all(query)
end)
# 1) check if jobname exist already
# 2) check if jobname has already jobnumber and build_timestamp


#Repo.insert(%TestsFailures{testname: "foo", count_failed: 1,  build_timestamp: 1233122, jobname: "foo", jobnumber: 23123})
