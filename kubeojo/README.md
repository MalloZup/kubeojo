# Kubeojo

# Elixir setup 

Kubeojo is based on elixir and phoenix frameworks.

* [Install elixir](https://elixir-lang.org/install.html)

* [configuration](https://github.com/MalloZup/kubeojo#configuration)
   you need to configure jenkins user and jobs to be fetched.

## Phoenix setup

You need to have postgres installed in order to develop with phoenix.


To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  

## Full the database with Jenkins jobs data

Atm you need to do :

this will open a elixir shell
```elixir

/bin/kubeojo/kubeojo$ iex -S mix
```

execute the function to put data in db
```elixir
Kubeojo.Jenkins.write_tests_failures_to_db

```

## starting the web-framework

* Start Phoenix endpoint with `mix phoenix.server`
* Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
