defmodule Bind.ParseTest do
  use ExUnit.Case
  doctest Bind.Parse

  alias Bind.Parse

  describe "sort_field/1" do
    test "returns ascending order for fields without a minus prefix" do
      assert Parse.sort_field("name") == [asc: :name]
      assert Parse.sort_field("age") == [asc: :age]
    end

    test "returns descending order for fields with a minus prefix" do
      assert Parse.sort_field("-name") == [desc: :name]
      assert Parse.sort_field("-age") == [desc: :age]
    end
  end

  describe "where_field/1" do
    test "correctly parses valid where parameters" do
      assert Parse.where_field("name[eq]") == [:name, "eq"]
      assert Parse.where_field("age[gte]") == [:age, "gte"]
    end

    test "returns nil for invalid where parameters" do
      assert Parse.where_field("invalid") == nil
      assert Parse.where_field("name[eq") == nil
      assert Parse.where_field("name]eq[") == nil
    end
  end

end
