defmodule Kubeojo.TestsFailures do
  use Kubeojo.Web, :model

  schema "tests_failures" do

    field :testname, :string
    field :count_failed, :integer
    field :build_timestamp, :integer
    field :jobname, :string
    field :jobnumber, :integer

    timestamps()
  end
end
