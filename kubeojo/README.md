# Kubeojo

# Elixir setup 

Kubeojo is built with Elixir and the Phoenix framework.

* [Install Elixir](https://elixir-lang.org/install.html)

* [Configuration](https://github.com/MalloZup/kubeojo#configuration)
   - you need to configure a Jenkins user and the jobs to be fetched.

## Phoenix setup

You need to have Postgres installed in order to develop with Phoenix.


To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  

## Fill the database with Jenkins jobs data

Open a Elixir shell:
```elixir

/bin/kubeojo/kubeojo$ iex -S mix
```

Execute the function to put data in the database:
```elixir
Kubeojo.Jenkins.write_tests_failures_to_db

```

## Starting the web framework

* Start Phoenix endpoint with `mix phoenix.server`
* Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
