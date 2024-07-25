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

  describe "constraint/3" do
    test "eq constraint" do
      query = Parse.constraint(:name, "eq", "Alice")
      assert inspect(query) =~ "r.name == ^\"Alice\""
    end

    test "neq constraint" do
      query = Parse.constraint(:name, "neq", "Bob")
      assert inspect(query) =~ "r.name != ^\"Bob\""
    end

    test "gt constraint" do
      query = Parse.constraint(:age, "gt", 30)
      assert inspect(query) =~ "r.age > ^30"
    end

    test "gte constraint" do
      query = Parse.constraint(:age, "gte", 30)
      assert inspect(query) =~ "r.age >= ^30"
    end

    test "lt constraint" do
      query = Parse.constraint(:age, "lt", 30)
      assert inspect(query) =~ "r.age < ^30"
    end

    test "lte constraint" do
      query = Parse.constraint(:age, "lte", 30)
      assert inspect(query) =~ "r.age <= ^30"
    end

    test "true constraint" do
      query = Parse.constraint(:active, "true", true)
      assert inspect(query) =~ "r.active == true"
    end

    test "false constraint" do
      query = Parse.constraint(:active, "false", false)
      assert inspect(query) =~ "r.active == false"
    end

    test "starts_with constraint" do
      query = Parse.constraint(:name, "starts_with", "A")
      assert inspect(query) =~ "ilike(r.name, ^\"%A\")"
    end

    test "ends_with constraint" do
      query = Parse.constraint(:name, "ends_with", "e")
      assert inspect(query) =~ "ilike(r.name, ^\"e%\")"
    end

    test "in constraint" do
      query = Parse.constraint(:status, "in", "active,pending")
      assert inspect(query) =~ "r.status in ^[\"active\", \"pending\"]"
    end

    test "contains constraint" do
      query = Parse.constraint(:description, "contains", "important")
      assert inspect(query) =~ "ilike(r.description, ^\"%important%\")"
    end

    test "nil constraint with true" do
      query = Parse.constraint(:deleted_at, "nil", "true")
      assert inspect(query) =~ "is_nil(r.deleted_at)"
    end

    test "nil constraint with false" do
      query = Parse.constraint(:deleted_at, "nil", "false")
      assert inspect(query) =~ "not is_nil(r.deleted_at)"
    end

    test "invalid constraint" do
      assert Parse.constraint(:name, "invalid", "value") == {:error, "Invalid constraint: invalid"}
    end
  end
end
