# Bind

Flexible and dynamic Ecto query builder for Elixir applications, allowing developers to retrieve data flexibly without writing custom queries for each use case.

## Installation

Add `bind` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bind, "~> 0.1.0"}
  ]
end
```

## Usage

To build dynamic Ecto queries based on given parameters:

```elixir
params = %{"name[eq]" => "Alice", "age[gte]" => 30, "sort" => "-age", "limit" => 10}
query = Bind.query(MyApp.User, params)
results = Repo.all(query)
```

This will return an Ecto query that can be executed using your Repo.

### Parameters

-   `schema`: The Ecto schema module (e.g., `MyApp.User`).
-   `params`: A map of query parameters or a query string.

### Filtering

Example:

```ex
%{"name[eq]" => "Alice", "age[gte]" => 30}
```

Bind supports various comparison operators for filtering:

-   `eq`: Equal to
-   `neq`: Not equal to
-   `gt`: Greater than
-   `gte`: Greater than or equal to
-   `lt`: Less than
-   `lte`: Less than or equal to
-   `true`: Boolean true
-   `false`: Boolean false
-   `starts_with`: String starts with
-   `ends_with`: String ends with
-   `in`: In a list of values
-   `contains`: String contains
-   `nil`: Is nil (or is not nil)

### Sorting

Use the `sort` parameter to specify sorting order:

-   Prefix with `-` for descending order
-   No prefix for ascending order

```ex
params = %{"sort" => "-age"}  # Sort by age descending
```

### Pagination

-   `limit`: Specify the maximum number of results (default: 10)
-   `start`: Specify the starting ID for pagination

Example:

```ex
params = %{"limit" => 20, "start" => 100}
```

### Query String Support

Bind can also pass URL query strings:

```ex
query_string = "?name[eq]=Alice&age[gte]=30&sort=-age&limit=10"
query = Bind.query(MyApp.User, query_string)
```
