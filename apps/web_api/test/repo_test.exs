defmodule AC.WebApi.RepoTest do
  use ExUnit.Case, async: true

  alias AC.WebApi.Repo
  alias AC.WebApi.Test.Faker

  describe "Repo.init/1" do
    test "process exits when table name is not passed" do
      assert {:error, :table_name_missing} = Repo.start_link([])
    end

    test "process exits when table_name is not atom" do
      assert {:error, :table_name_invalid} = Repo.start_link(table_name: "string")
    end

    test "process created for valid table name" do
      {:ok, table_name} = AC.WebApi.Helpers.AppConfig.get_table_name()
      assert {:ok, pid} = start_supervised({Repo, table_name: table_name}, restart: :temporary)

      assert Process.alive?(pid)
      assert %{table_name: ^table_name} = :sys.get_state(Repo)
    end
  end

  describe "Repo.insert_or_update/2" do
    setup :with_repo

    test "creates table if it doesn't exist", c do
      file_name = c.table_name |> Atom.to_string()
      assert file_name |> File.exists?() |> Kernel.not()
      assert :ok = Repo.insert_or_update(Faker.generate(:uuid), %{})
      assert file_name |> File.exists?()
    end

    test "updates value if key exists" do
      key = Faker.generate(:uuid)
      assert :ok = Repo.insert_or_update(key, %{})
      %{} = map = Repo.get(key)
      assert map_size(map) == 0
      assert :ok = Repo.insert_or_update(key, %{a: 1})
      %{a: 1} = Repo.get(key)
    end
  end

  describe "Repo.exists?/1" do
    setup :with_repo

    test "returns false for key that does not exist" do
      assert false == Repo.exists?(1)
    end

    test "returns true for existing key" do
      key = Faker.generate(:uuid)
      map = %{a: 1}
      Repo.insert_or_update(key, map)
      assert true == Repo.exists?(key)
    end
  end

  describe "Repo.get/1" do
    setup :with_repo

    test "returns nil for key that does not exist" do
      assert nil == Repo.get(Faker.generate(:uuid))
    end

    test "returns value for existing key" do
      key = Faker.generate(:uuid)
      map = %{a: 1}
      Repo.insert_or_update(key, map)
      assert ^map = Repo.get(key)
    end
  end

  describe "Repo.get_all/1" do
    setup :with_repo

    test "returns empty list for no values" do
      assert [] = Repo.get_all()
    end

    test "returns list of all values" do
      with_five_values(:_)
      list = Repo.get_all()
      assert length(list) == 5
    end
  end

  describe "Repo.delete/1" do
    setup :with_repo
    setup :with_five_values

    test "returns :ok for key that doesn't exit" do
      assert :ok = Repo.delete(10)
    end

    test "returns :ok for key that exists", c do
      key = c.keys |> Enum.random()
      assert %{} = Repo.get(key)
      assert :ok = Repo.delete(key)
      assert nil == Repo.get(key)
    end
  end

  def with_repo(_c) do
    table_name = :repo_tests
    {:ok, _pid} = start_supervised({Repo, table_name: table_name}, restart: :temporary)

    on_exit(fn ->
      table_name
      |> Atom.to_string()
      |> File.exists?()
      |> if do
        :ok = File.rm(to_string(table_name))
      end

      :ok
    end)

    [table_name: table_name]
  end

  def with_five_values(_c) do
    enums = 1..5

    enums
    |> Enum.map(&Repo.insert_or_update(&1, %{a: &1}))

    [keys: Enum.to_list(enums)]
  end
end
