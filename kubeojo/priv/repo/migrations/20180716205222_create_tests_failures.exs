defmodule Kubeojo.Repo.Migrations.CreateTestsFailures do
  use Ecto.Migration

  def change do
    create table(:tests_failures) do
       add :testname, :string
       add :build_timestamp, :bigint
       add :jobname, :string
       add :jobnumber, :bigint

       timestamps()
    end
  end
end
