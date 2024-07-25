# Bind

Flexible and dynamic Ecto query builder for Elixir applications, allowing developers to retrieve data flexibly without writing custom queries for each use case.

```ex
# curl /users?email[contains]=gmail&sort=-created_at&limit=10

get "/users" do
    query = Bind.query(User, conn.query_params)
    users = Repo.all(query)
    send_resp(conn, 200, Jason.encode!(%{data: users}))
end
```

## Installation

Add `bind` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bind, "~> 0.1.0"}
  ]
end
```

## API

```ex
Bind.query(schema, params)
```

Parameters:

-   `schema`: The Ecto schema module (e.g., `MyApp.User`).
-   `params`: Either a map of query parameters or a query string.

Returns: An Ecto query.

## Usage Example

Create Ecto query:

```ex
query = Bind.query(MyApp.User, %{ "name[eq]" => "Alice", "age[gte]" => 30 })
```

Alternatively, with a query string:

```ex
query = Bind.query(MyApp.User, "?name[eq]=Alice&age[gte]=30")
```

And finally run the query to get results from the database:

```ex
results = Repo.all(query)
```

Error handling

```ex
case Bind.query(MyApp.User, %{ "name[eq]" => "Alice", "age[gte]" => 30 }) do
  {:error, reason} ->
    IO.puts("Error building query: #{reason}")

  query ->
    results = Repo.all(query)
end
```

### Filtering

Examples:

```ex
%{"name[eq]" => "Alice", "age[gte]" => 30}
```

```ex
%{
  "name[starts_with]" => "A",
  "age[gte]" => 18,
  "role[in]" => "superuser,admin,mod",
  "is_active[true]" => "",
  "last_login[nil]" => false
}
```

List of comparison operators supported:

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
%{"sort" => "-age"}  # Sort by age descending
%{"sort" => "age"}  # Sort by age ascending
```

If nothing specified, sorts by ID field ascending.

### Pagination

-   `limit`: Specify the maximum number of results (default: 10)
-   `start`: Specify the starting ID for pagination

Example:

```ex
%{"limit" => 20, "start" => 100}
```

### Query String Support

Bind can also pass URL query strings:

```ex
query_string = "?name[eq]=Alice&age[gte]=30&sort=-age&limit=10"
query = Bind.query(MyApp.User, query_string)
```
