defmodule Bind.Parse do
  import Ecto.Query

  @doc """
  Parses the sort parameter to determine the sort direction and field.

  ## Parameters
    - `param`: The sort parameter as a string.

  ## Examples

      > Bind.Parse.sort_field("-age")
      [desc: :age]

      > Bind.Parse.sort_field("name")
      [asc: :name]

  """
  def sort_field(param) do
    case String.starts_with?(param, "-") do
      true ->
        [desc: String.to_atom(String.trim(param, "-"))]

      false ->
        [asc: String.to_atom(param)]
    end
  end

  @doc """
  Parses a where parameter to extract the field name and constraint.

  ## Parameters
    - `param`: The where parameter as a string.

  ## Examples

      > Bind.Parse.where_field("name[eq]")
      [:name, "eq"]

      > Bind.Parse.where_field("age[gte]")
      [:age, "gte"]

  """
  def where_field(param) do
    case Regex.match?(~r/^\w+\[\w+\]$/, param) do
      true ->
        [prop, constraint] = String.split(param, "[")
        constraint = String.trim(constraint, "]")
        [String.to_atom(prop), constraint]

      false ->
        nil
    end
  end
end
