defmodule Kubeojo do
  require HTTPoison
  @moduledoc """
  Documentation for Kubeojo.
  """
  @doc """
  Hello world.

  ## Examples

      iex> Kubeojo.hello
      :world

  """
  # jenkins specific:
  # 
  # we need to consider failed and regression as valid states for counting.
  # 
  # FAILED
  # This test failed, just like its previous run.
  # REGRESSION
  # This test has been running OK, but now it failed.
  def get_credentials do
    user = "opensuse"
    pwd = "yourpwd" 
    [user, pwd] 
  end


  def login do
    [user, pwd]  = get_credentials()
    headers = ["Authorization": "#{user} #{pwd}", "Accept": "Application/json; Charset=utf-8"]
    url = "https://ci.suse.de/view/Manager/view/Manager-3.1/job/manager-3.1-cucumber/3045/testReport/api/json"
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 50000]
    case HTTPoison.get(url, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        # extract in body the status and the testname
        IO.puts body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end
end
