defmodule Bind.QueryString do
  @moduledoc """
  Provides functionality to convert a query string from a URL into a map.
  """

  @doc """
  Converts a query string from a URL into a map, converting numerical values to number type.

  ## Parameters
    - `query_string`: The query string from a URL.

  ## Examples

      iex> Bind.QueryString.to_map("?name[eq]=Alice&age[gte]=30&sort=-age&limit=10")
      %{"name[eq]" => "Alice", "age[gte]" => 30, "sort" => "-age", "limit" => 10}

  """
  def to_map(query_string) do
    query_string
    |> String.trim_leading("?")
    |> URI.decode_query()
    |> Enum.map(fn {key, value} -> {key, convert_value(value)} end)
    |> Enum.into(%{})
  end

  defp convert_value(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ ->
        case Float.parse(value) do
          {float, ""} -> float
          _ -> value
        end
    end
  end
end
