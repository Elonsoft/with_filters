defmodule WithFilters do
  @moduledoc """
  Helper for list query filters.

  Use it as follows:

  ```
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

  ```
  use WithFilters, empty_for: ["some_filter"]
  ```

  You will be warned about all the filters that are not specified with
  warnings.

  """

  @callback with_filter({String.t() | atom(), term()}, Ecto.Query.t()) :: Ecto.Query.t()

  defmacro __using__(opts) do
    empty_filters =
      case opts[:empty_for] do
        nil ->
          []

        filters ->
          for f <- filters do
            quote do
              @impl WithFilters
              def with_filter({unquote(f), _}, query), do: query
            end
          end
      end

    quote do
      @behaviour WithFilters

      require Logger

      defp with_filters(query, filters) do
        Enum.reduce(filters, query, &with_filter/2)
      end

      @impl WithFilters
      def with_filter({filter_atom, value}, query) when is_atom(filter_atom) do
        filter = filter_atom |> to_string()
        with_filter({filter, value}, query)
      end

      unquote(empty_filters)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @impl WithFilters
      def with_filter({filter, _}, query) do
        Logger.warn("Unhandled filter in #{__MODULE__}: #{filter}")
        query
      end
    end
  end
end
