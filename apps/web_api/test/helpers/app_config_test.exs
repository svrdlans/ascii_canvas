defmodule AC.WebApi.Helpers.AppConfigTest do
  use ExUnit.Case

  alias AC.WebApi.Helpers.AppConfig

  @default_repo AC.WebApi.Repo

  describe "AppConfig.get_repo_config/0" do
    test "returns error tuple when table name doesn't exist" do
      Application.put_env(:ac_web_api, :repo, [])
      assert {:error, :table_name_invalid} = AppConfig.get_repo_config()
    end

    test "returns error tuple when table name is nil" do
      Application.put_env(:ac_web_api, :repo, table_name: nil)
      assert {:error, :table_name_invalid} = AppConfig.get_repo_config()
    end

    test "returns error tuple when table name is not an atom" do
      Application.put_env(:ac_web_api, :repo, table_name: "tet")
      assert {:error, :table_name_invalid} = AppConfig.get_repo_config()

      Application.put_env(:ac_web_api, :repo, table_name: 2434)
      assert {:error, :table_name_invalid} = AppConfig.get_repo_config()
    end

    test "returns default repo name when name doesn't exist" do
      table_name = :table
      Application.put_env(:ac_web_api, :repo, table_name: table_name)
      assert {:ok, [table_name: ^table_name, name: @default_repo]} = AppConfig.get_repo_config()
    end

    test "returns default repo name when name is nil" do
      table_name = :table
      Application.put_env(:ac_web_api, :repo, table_name: table_name, name: nil)
      assert {:ok, [table_name: ^table_name, name: @default_repo]} = AppConfig.get_repo_config()
    end

    test "returns error tuple when name is not an atom" do
      table_name = :table
      Application.put_env(:ac_web_api, :repo, table_name: table_name, name: "name")
      assert {:error, :name_invalid} = AppConfig.get_repo_config()
    end

    test "returns error tuple when table name and name are not atoms" do
      Application.put_env(:ac_web_api, :repo, table_name: "table", name: "name")
      assert {:error, :table_name_invalid} = AppConfig.get_repo_config()
    end

    test "returns full repo config" do
      table_name = :table
      name = ConfigTest
      Application.put_env(:ac_web_api, :repo, table_name: table_name, name: name)
      assert {:ok, [table_name: ^table_name, name: ^name]} = AppConfig.get_repo_config()
    end
  end

  describe "AppConfig.get_repo_table_name/0" do
    test "returns error tuple when table name is invalid" do
      Application.put_env(:ac_web_api, :repo, [])
      assert {:error, :table_name_invalid} = AppConfig.get_repo_table_name()

      Application.put_env(:ac_web_api, :repo, table_name: nil)
      assert {:error, :table_name_invalid} = AppConfig.get_repo_table_name()

      Application.put_env(:ac_web_api, :repo, table_name: "tet")
      assert {:error, :table_name_invalid} = AppConfig.get_repo_table_name()

      Application.put_env(:ac_web_api, :repo, table_name: 2434)
      assert {:error, :table_name_invalid} = AppConfig.get_repo_table_name()
    end

    test "returns ok tuple when table name is valid" do
      table_name = :table
      Application.put_env(:ac_web_api, :repo, table_name: table_name)
      assert {:ok, ^table_name} = AppConfig.get_repo_table_name()
    end
  end

  describe "AppConfig.get_repo_name/0" do
    test "returns error tuple when name is invalid" do
      Application.put_env(:ac_web_api, :repo, name: "ets")
      assert {:error, :name_invalid} = AppConfig.get_repo_name()

      Application.put_env(:ac_web_api, :repo, name: 234)
      assert {:error, :name_invalid} = AppConfig.get_repo_name()
    end

    test "returns default name when name is nil or missing" do
      Application.put_env(:ac_web_api, :repo, [])
      assert {:ok, @default_repo} = AppConfig.get_repo_name()

      Application.put_env(:ac_web_api, :repo, name: nil)
      assert {:ok, @default_repo} = AppConfig.get_repo_name()
    end

    test "returns ok tuple when table name is valid" do
      name = Tester
      Application.put_env(:ac_web_api, :repo, name: name)
      assert {:ok, ^name} = AppConfig.get_repo_name()
    end
  end
end
