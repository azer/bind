defmodule Bind.QueryBuilder do
  import Ecto.Query

  def add_limit_query(query, params) do
    case Map.get(params, "limit") do
      nil ->
        Ecto.Query.limit(query, [r], 10)

      limit_param when is_integer(limit_param) ->
        Ecto.Query.limit(query, [r], ^limit_param)

      limit_param when is_binary(limit_param) ->
        Ecto.Query.limit(query, [r], ^String.to_integer(limit_param))
    end
  end

  def add_offset_query(query, params) do
    case Map.get(params, "start") do
      nil ->
        query

      start_id ->
        Ecto.Query.where(query, [r], field(r, :id) > ^start_id)
    end
  end

  def build_where_query(params) do
    Enum.reduce(params, Ecto.Query.dynamic(true), fn {param, param_value}, dynamic ->
      case Bind.Parse.where_field(param) do
        nil ->
          dynamic

        [prop, constraint] ->
          case Bind.Parse.constraint(prop, constraint, param_value) do
            {:error, reason} ->
              dynamic

            constraint ->
              dynamic([r], ^dynamic and ^constraint)
          end
      end
    end)
  end

  def build_sort_query(params) do
    case params["sort"] do
      nil -> [asc: :id]
      "" -> [asc: :id]
      sort_param -> Bind.Parse.sort_field(sort_param)
    end
  end

end
