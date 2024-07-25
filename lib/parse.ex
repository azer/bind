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

  @doc """
  Parses a constraint and returns a dynamic query fragment.

  ## Parameters
    - `field`: The field to apply the constraint to.
    - `constraint`: The type of constraint (e.g., "eq", "gte").
    - `value`: The value to compare the field against.

  ## Examples

      > Bind.Parse.constraint(:name, "eq", "Alice")
      dynamic([r], r.name == ^"Alice")

      > Bind.Parse.constraint(:age, "gte", 30)
      dynamic([r], r.age > ^30)

  """
  def constraint(field, "eq", value) do
    dynamic([r], field(r, ^field) == ^value)
  end

  def constraint(field, "neq", value) do
    dynamic([r], field(r, ^field) != ^value)
  end

  def constraint(field_name, "gt", value) do
    dynamic([r], field(r, ^field_name) > ^value)
  end

  def constraint(field_name, "gte", value) do
    dynamic([r], field(r, ^field_name) >= ^value)
  end

  def constraint(field, "lt", value) do
    dynamic([r], field(r, ^field) < ^value)
  end

  def constraint(field, "lte", value) do
    dynamic([r], field(r, ^field) <= ^value)
  end

  def constraint(field, "true", _value) do
    dynamic([r], field(r, ^field) == true)
  end

  def constraint(field, "false", _value) do
    dynamic([r], field(r, ^field) == false)
  end

  def constraint(field, "starts_with", value) do
    dynamic([r], ilike(field(r, ^field), ^"%#{value}"))
  end

  def constraint(field, "ends_with", value) do
    dynamic([r], ilike(field(r, ^field), ^"#{value}%"))
  end

  def constraint(field, "in", value) do
    values = String.split(value, ",")
    dynamic([r], field(r, ^field) in ^values)
  end

  def constraint(field, "contains", value) do
    dynamic([r], ilike(field(r, ^field), ^"%#{value}%"))
  end

  def constraint(field, "nil", value) when value in ["true", true] do
    dynamic([r], is_nil(field(r, ^field)))
  end

  def constraint(field, "nil", value) when value in ["false", false] do
    dynamic([r], not is_nil(field(r, ^field)))
  end

  def constraint(_field, constraint, _value) do
    # Here we add an error clause that matches any unknown constraint.
    {:error, "Invalid constraint: #{constraint}"}
  end
end
