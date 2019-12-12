# WithFilters

Helper for list query filters.

Use it as follows:

```elixir
  use WithFilters

  def list_users() do
    User
    |> with_filters(%{"status" => "active", "in_group" => 1})
    |> Repo.all()
  end

  @impl WithFilters
  def with_filter({"status", "active"}, query) do
    from r in query, where: r.status == "active"
  end

  @impl WithFilters
  def with_filter({"in_group", id}, query) do
    from r in query,
      join: g in assoc(r, :groups),
      where: ^id == g.id
  end
```

You may want to define callbacks that ignore some wilters:

```elixir
  use WithFilters, empty_for: ["some_filter"]
```

You will be warned about all the filters that are not specified with
warnings.

## Installation

The package can be installed by adding `with_filters` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:with_filters, github: "Elonsoft/with_wilters", branch: "master"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc).
