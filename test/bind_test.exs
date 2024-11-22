defmodule BindTest do
  use ExUnit.Case
  doctest Bind

  defmodule User do
    use Ecto.Schema

    schema "users" do
      field(:name, :string)
      field(:age, :integer)
      field(:active, :boolean)
    end
  end

  test "builds a query with where, order, limit, and offset clauses" do
    params = %{
      "name[eq]" => "Alice",
      "age[gte]" => 30,
      "sort" => "-age",
      "limit" => "5",
      "start" => 10
    }

    query = params |> Bind.query(User) # updated to use pipe
    query_string = inspect(query)

    assert query_string =~ "from u0 in BindTest.User"
    assert query_string =~ "name == ^\"Alice\""
    assert query_string =~ "age >= ^30"
    assert query_string =~ "order_by: [desc: u0.age]"
    assert query_string =~ "limit: ^5"
    assert query_string =~ "id > ^10"
  end
end
