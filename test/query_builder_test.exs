defmodule Bind.QueryBuilderTest do
  use ExUnit.Case
  doctest Bind.QueryBuilder

  alias Bind.QueryBuilder

  # Define a sample schema for testing
  defmodule User do
    use Ecto.Schema

    schema "users" do
      field(:name, :string)
      field(:age, :integer)
      field(:active, :boolean)
    end
  end

  describe "add_limit_query/2" do
    test "adds default limit when not specified" do
      query = QueryBuilder.add_limit_query(User, %{})
      assert inspect(query) =~ "limit: 10"
    end

    test "adds specified integer limit" do
      query = QueryBuilder.add_limit_query(User, %{"limit" => 20})
      assert inspect(query) =~ "limit: ^20"
    end

    test "adds specified string limit" do
      query = QueryBuilder.add_limit_query(User, %{"limit" => "15"})
      assert inspect(query) =~ "limit: ^15"
    end
  end

  describe "add_offset_query/2" do
    test "does not add offset when not specified" do
      query = QueryBuilder.add_offset_query(User, %{})
      refute inspect(query) =~ "where: u0.id >"
    end

    test "adds offset when specified" do
      query = QueryBuilder.add_offset_query(User, %{"start" => 5})
      assert inspect(query) =~ "where: u0.id > ^5"
    end
  end

  describe "build_where_query/1" do
    test "builds where query with multiple conditions" do
      params = %{
        "name[eq]" => "Bob",
        "age[gte]" => 25,
        "active[eq]" => true
      }

      query = QueryBuilder.build_where_query(params)
      query_string = inspect(query)

      assert query_string =~ "name == ^\"Bob\""
      assert query_string =~ "age >= ^25"
      assert query_string =~ "active == ^true"
    end

    test "returns error when an invalid constraint is provided" do
      params = %{
        "name[eq]" => "Alice",
        "age[invalid]" => 30
      }

      result = QueryBuilder.build_where_query(params)
      assert {:error, "Invalid constraint: age[invalid]"} = result
    end
  end

  describe "build_sort_query/1" do
    test "returns default sort when not specified" do
      assert QueryBuilder.build_sort_query(%{}) == [asc: :id]
    end

    test "returns default sort when empty string" do
      assert QueryBuilder.build_sort_query(%{"sort" => ""}) == [asc: :id]
    end

    test "returns ascending sort" do
      assert QueryBuilder.build_sort_query(%{"sort" => "name"}) == [asc: :name]
    end

    test "returns descending sort" do
      assert QueryBuilder.build_sort_query(%{"sort" => "-age"}) == [desc: :age]
    end
  end
end
