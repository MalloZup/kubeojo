# filter junit data
defmodule Kubeojo.Jenkins.JunitParser do
  @spec name_and_status(map()) :: map()
  def name_and_status(%{"suites" => suites}) do
    status = get_in(suites, [Access.all(), "cases", Access.all(), "status"]) |> List.flatten()
    name = get_in(suites, [Access.all(), "cases", Access.all(), "name"]) |> List.flatten()
    Enum.zip(name, status) |> Enum.into(%{})
  end

  # from results filter and keep only failed tests
  @spec failed_only(any()) :: [any()]
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
