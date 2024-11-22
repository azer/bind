defmodule Bind.FilterTest do
  use ExUnit.Case

  defmodule Post do
    use Ecto.Schema

    schema "posts" do
      field :title, :string
      field :user_id, :integer
      field :team_id, :integer
      field :active, :boolean
    end
  end

  test "composes multiple filters" do
    query_string = "title[contains]=test&sort=-id"

    query = query_string
      |> Bind.filter(%{"user_id[eq]" => 123})
      |> Bind.filter(%{"team_id[eq]" => 456})
      |> Bind.query(Post)

    assert inspect(query) =~ "ilike(p0.title, ^\"%test%\")"
    assert inspect(query) =~ "p0.user_id == ^123"
    assert inspect(query) =~ "p0.team_id == ^456"
  end

  test "later filters override earlier ones" do
    params = %{"user_id[eq]" => 123}

    filtered = params
      |> Bind.filter(%{"user_id[eq]" => 456})

    assert filtered["user_id[eq]"] == 456
  end

  test "works with both maps and query strings" do
    result1 = Bind.filter("a[eq]=1", %{"b[eq]" => 2})
    result2 = Bind.filter(%{"a[eq]" => 1}, %{"b[eq]" => 2})

    assert result1 == result2
  end
end
