defmodule AC.WebApi.RepoTest do
  use ExUnit.Case, async: true

  alias AC.WebApi.Repo
  alias AC.WebApi.Test.Faker

  describe "Repo.init/1" do
    test "process exits when table name is not passed" do
      assert {:error, :table_name_missing} = Repo.start_link(name: Missing)
    end

    test "process exits when table_name is not atom" do
      assert {:error, :table_name_invalid} = Repo.start_link(table_name: "string", name: Invalid)
    end

    test "process created for valid table name" do
      {:ok, table_name} = AC.WebApi.Helpers.AppConfig.get_repo_table_name()

      assert {:ok, pid} =
               start_supervised({Repo, table_name: table_name, name: RepoTest},
                 restart: :temporary
               )

      assert Process.alive?(pid)
      assert %{table_name: ^table_name} = :sys.get_state(RepoTest)
    end
  end

  describe "Repo.insert_or_update/2" do
    setup :with_repo

    test "creates table if it doesn't exist", %{repo: repo} = c do
      file_name = c.table_name |> Atom.to_string()
      assert file_name |> File.exists?() |> Kernel.not()
      assert :ok = Repo.insert_or_update(repo, Faker.generate(:uuid), %{})
      assert file_name |> File.exists?()
    end

    test "updates value if key exists", %{repo: repo} do
      key = Faker.generate(:uuid)
      assert :ok = Repo.insert_or_update(repo, key, %{})
      %{} = map = Repo.get(repo, key)
      assert map_size(map) == 0
      assert :ok = Repo.insert_or_update(repo, key, %{a: 1})
      %{a: 1} = Repo.get(repo, key)
    end
  end

  describe "Repo.exists?/1" do
    setup :with_repo

    test "returns false for key that does not exist", c do
      assert false == Repo.exists?(c.repo, 1)
    end

    test "returns true for existing key", %{repo: repo} do
      key = Faker.generate(:uuid)
      map = %{a: 1}
      Repo.insert_or_update(repo, key, map)
      assert true == Repo.exists?(repo, key)
    end
  end

  describe "Repo.get/1" do
    setup :with_repo

    test "returns nil for key that does not exist", %{repo: repo} do
      assert nil == Repo.get(repo, Faker.generate(:uuid))
    end

    test "returns value for existing key", %{repo: repo} do
      key = Faker.generate(:uuid)
      map = %{a: 1}
      Repo.insert_or_update(repo, key, map)
      assert ^map = Repo.get(repo, key)
    end
  end

  describe "Repo.get_all/1" do
    setup :with_repo

    test "returns empty list for no values", %{repo: repo} do
      assert [] = Repo.get_all(repo)
    end

    test "returns list of all values", %{repo: repo} = c do
      with_five_values(c)
      list = Repo.get_all(repo)
      assert length(list) == 5
    end
  end

  describe "Repo.delete/1" do
    setup :with_repo
    setup :with_five_values

    test "returns :ok for key that doesn't exit", %{repo: repo} do
      assert :ok = Repo.delete(repo, 10)
    end

    test "returns :ok for key that exists", %{repo: repo} = c do
      key = c.keys |> Enum.random()
      assert %{} = Repo.get(repo, key)
      assert :ok = Repo.delete(repo, key)
      assert nil == Repo.get(repo, key)
    end
  end

  def with_repo(_c) do
    table_name = :repo_tests
    name = RepoTest

    {:ok, _pid} =
      start_supervised({Repo, table_name: table_name, name: name}, restart: :temporary)

    on_exit(fn ->
      table_name
      |> Atom.to_string()
      |> File.exists?()
      |> if do
        :ok = File.rm(to_string(table_name))
      end

      :ok
    end)

    [table_name: table_name, repo: name]
  end

  def with_five_values(c) do
    enums = 1..5

    enums
    |> Enum.map(&Repo.insert_or_update(c.repo, &1, %{a: &1}))

    [keys: Enum.to_list(enums)]
  end
end
