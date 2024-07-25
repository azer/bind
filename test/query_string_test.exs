defmodule Bind.QueryStringTest do
  use ExUnit.Case
  alias Bind.QueryString

  describe "to_map/1" do
    test "converts query string to map" do
      query_string = "?name[eq]=Alice&age[gte]=30&sort=-age&limit=10"
      expected_map = %{"name[eq]" => "Alice", "age[gte]" => 30, "sort" => "-age", "limit" => 10}

      assert QueryString.to_map(query_string) == expected_map
    end

    test "handles empty query string" do
      query_string = "?"
      expected_map = %{}

      assert QueryString.to_map(query_string) == expected_map
    end

    test "handles query string without leading ?" do
      query_string = "name[eq]=Alice&age[gte]=30&sort=-age&limit=10"
      expected_map = %{"name[eq]" => "Alice", "age[gte]" => 30, "sort" => "-age", "limit" => 10}

      assert QueryString.to_map(query_string) == expected_map
    end
  end
end
