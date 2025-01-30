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

    query = Bind.query(params, User)
    query_string = inspect(query)

    assert query_string =~ "from u0 in BindTest.User"
    assert query_string =~ "name == ^\"Alice\""
    assert query_string =~ "age >= ^30"
    assert query_string =~ "order_by: [desc: u0.age]"
    assert query_string =~ "limit: ^5"
    assert query_string =~ "id > ^10"
  end

  test "builds query from query string" do
    # Test query string with multiple conditions
    url_params = "name[eq]=Alice&age[gte]=30&sort=-age&limit=5&start=10"

    query = Bind.query(url_params, User)
    query_string = inspect(query)

    # Assert query builds correctly
    assert query_string =~ "from u0 in BindTest.User"
    assert query_string =~ "name == ^\"Alice\""
    assert query_string =~ "age >= ^30"
    assert query_string =~ "order_by: [desc: u0.age]"
    assert query_string =~ "limit: ^5"
    assert query_string =~ "id > ^10"
  end

  test "handles query string with special characters" do
    url_params = "name[eq]=John%20Doe&description[contains]=Hello%20World"

    query = Bind.query(url_params, User)
    query_string = inspect(query)

    assert query_string =~ "name == ^\"John Doe\""
    assert query_string =~ "ilike(u0.description, ^\"%Hello World%\")"
  end

  test "maps values using field matchers" do
    params = "user_id[eq]=123&team_id[eq]=456&name[eq]=alice"

    mapped =
      Bind.map(params, %{
        user_id: fn id -> "u_#{id}" end,
        team_id: fn id -> "t_#{id}" end,
        name: &String.upcase/1
      })

    assert mapped == %{
             "user_id[eq]" => "u_123",
             "team_id[eq]" => "t_456",
             "name[eq]" => "ALICE"
           }
  end

  test "maps values using regex patterns" do
    params = "user_id[eq]=123&team_id[eq]=456&org_id[eq]=789"

    mapped =
      Bind.map(params, %{
        ~r/_id$/i => fn id -> "id_#{id}" end
      })

    assert mapped == %{
             "user_id[eq]" => "id_123",
             "team_id[eq]" => "id_456",
             "org_id[eq]" => "id_789"
           }
  end

  test "keeps unmapped fields unchanged" do
    params = "user_id[eq]=123&name[eq]=alice"

    mapped =
      Bind.map(params, %{
        user_id: fn id -> "u_#{id}" end
      })

    assert mapped == %{
             "user_id[eq]" => "u_123",
             # unchanged
             "name[eq]" => "alice"
           }
  end

  test "maps pagination parameters" do
    params = "start=encoded_123&lora_model_id[eq]=encoded_456"

    mapped =
      Bind.map(params, %{
        start: fn hash -> "decoded_#{hash}" end,
        lora_model_id: fn hash -> "decoded_#{hash}" end
      })

    # Verify the mapping worked
    assert mapped == %{
             "start" => "decoded_encoded_123",
             "lora_model_id[eq]" => "decoded_encoded_456"
           }

    # Verify the mapped values are used in the query
    query = Bind.query(mapped, User)
    query_string = inspect(query)

    assert query_string =~ "where: u0.id > ^\"decoded_encoded_123\""
    assert query_string =~ "lora_model_id == ^\"decoded_encoded_456\""
  end

  test "handles descending pagination with negative start parameter" do
    params = %{
      "sort" => "-id",
      "-start" => 100
    }

    query = Bind.query(params, User)
    query_string = inspect(query)

    # Should use < for descending order with negative start
    assert query_string =~ "where: u0.id < ^100"
    assert query_string =~ "order_by: [desc: u0.id]"
  end

  test "handles ascending pagination with positive start parameter" do
    params = %{
      "sort" => "id",
      "start" => "100"
    }

    query = Bind.query(params, User)
    query_string = inspect(query)

    # Should use > for ascending order
    assert query_string =~ "where: u0.id > ^\"100\""
    assert query_string =~ "order_by: [asc: u0.id]"
  end

  test "maps pagination parameters preserving negative start ID" do
    params = "-start=encoded_123&lora_model_id[eq]=encoded_456"

    mapped =
      Bind.map(params, %{
        start: fn id -> "decoded_" <> id end,
        lora_model_id: fn id -> "decoded_" <> id end
      })

    # Verify the mapping preserves the minus sign
    assert mapped == %{
      "-start" => "decoded_encoded_123",
      "lora_model_id[eq]" => "decoded_encoded_456"
    }

    # Verify the mapped values are used correctly in the query
    query = Bind.query(mapped, User)
    query_string = inspect(query)

    assert query_string =~ "where: u0.id < ^\"decoded_encoded_123\""
  end

  test "maps start parameter to number" do
    # Test positive number
    params = "start=anything"
    mapped = Bind.map(params, %{
	  start: fn _id -> 123 end
		      })

    assert mapped == %{
      "start" => 123
    }

    query = Bind.query(mapped, User)
    query_string = inspect(query)
    assert query_string =~ "where: u0.id > ^123"
  end
end
