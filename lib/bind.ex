defmodule Bind do
  import Ecto.Query

  @moduledoc """
  `Bind` provides functionality to build dynamic Ecto queries based on given parameters.
  It allows developers to retrieve data flexibly without writing custom queries for each use case.

  ## Examples

  Given an Ecto schema module `MyApp.User` and a map of query parameters, you can build and run a query like this:

      > params = %{ "name[eq]" => "Alice", "age[gte]" => 30, "sort" => "-age", "limit" => "10" }
      > query = Bind.query(MyApp.User, params)
      > results = Repo.all(query)
      > IO.inspect(results)
  """

  @doc """
  Builds an Ecto query for the given schema based on the provided parameters.

  ## Parameters
    - `schema`: The Ecto schema module (e.g., `MyApp.User`).
    - `params`: A map of query parameters.

  ## Examples

      > params = %{"name[eq]" => "Alice", "age[gte]" => "30", "sort" => "-age"}
      > Bind.query(MyApp.User, params)
      #Ecto.Query<from u0 in MyApp.User, where: u0.name == ^"Alice", where: u0.age >= ^30, order_by: [desc: u0.age]>

  """
  def query(params, schema) when is_map(params) do
    case Bind.QueryBuilder.build_where_query(params) do
      {:error, reason} -> {:error, reason}

      where_query ->
        sort_query = Bind.QueryBuilder.build_sort_query(params)

        schema
        |> where(^where_query)
        |> order_by(^Enum.into(sort_query, []))
        |> Bind.QueryBuilder.add_limit_query(params)
        |> Bind.QueryBuilder.add_offset_query(params)
    end
  end

  @doc """
  Builds an Ecto query for the given schema based on the provided query string.

  ## Parameters
    - `schema`: The Ecto schema module (e.g., `MyApp.User`).
    - `query_string`: The query string from a URL.

  ## Examples
      > query_string = "?name[eq]=Alice&age[gte]=30&sort=-age&limit=10"
      > Bind.query(MyApp.User, query_string)
      #Ecto.Query<from u0 in MyApp.User, where: u0.name == ^"Alice", where: u0.age >= ^30, order_by: [desc: u0.age]>
  """
  def query(query_string, schema) when is_binary(query_string) do
    query_string
    |> Bind.QueryString.to_map()
    |> query(schema)
  end
end
