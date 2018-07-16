defmodule Kubeojo.Repo.Migrations.CreateTestsFailures do
  use Ecto.Migration

  def change do
    create table(:tests_failures) do
       add :testname, :string
       add :count_failed, :integer
       add :build_timestamp, :integer
       add :jobname, :string
       add :jobnumber, :integer

       timestamps()
    end
  end
end
