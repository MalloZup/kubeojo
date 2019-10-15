defmodule Kubeojo.JenkinsControllerTest do
  use Kubeojo.ConnCase

  describe "GET /" do
    test "It renders successfully if given no params", %{conn: conn} do
      conn = get(conn, "/")
      assert conn.status == 200
    end

    test "It renders the links to jobnames", %{conn: conn} do
      conn = get(conn, "/")
      html_resp = html_response(conn, 200)
      for jobname <- conn.assigns.jenkins do
        assert String.contains?(html_resp, "/jenkins/#{jobname}")
      end
    end
  end

  describe "GET /:jobname" do
    test "It renders successfully if route contains valid jobname", %{conn: conn} do
      jobname = get_random_jobname()
      conn = get(conn, "/jenkins/#{jobname}")
      assert conn.status == 200
    end

    test "It contains jobname", %{conn: conn} do
      jobname = get_random_jobname()
      conn = get(conn, "/jenkins/#{jobname}")
      html_resp = html_response(conn, 200)
      assert String.contains?(html_resp, "<h1>#{jobname}</h1>")
    end
  end


  defp get_random_jobname() do
    jobnames = Kubeojo.Yaml.jenkins_jobs()
    Enum.random(jobnames)
  end
end
