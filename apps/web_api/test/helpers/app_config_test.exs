defmodule AC.WebApi.Helpers.AppConfigTest do
  use ExUnit.Case

  alias AC.WebApi.Helpers.AppConfig

  describe "AppConfig.get_table_name/0" do
    test "returns error tuple when table name is invalid" do
      Application.put_env(:ac_web_api, :table_name, nil)
      assert {:error, :table_name_invalid} = AppConfig.get_table_name()

      Application.put_env(:ac_web_api, :table_name, "tet")
      assert {:error, :table_name_invalid} = AppConfig.get_table_name()

      Application.put_env(:ac_web_api, :table_name, 2434)
      assert {:error, :table_name_invalid} = AppConfig.get_table_name()
    end

    test "returns ok tuple when table name is valid" do
      table_name = :table
      Application.put_env(:ac_web_api, :table_name, table_name)
      assert {:ok, ^table_name} = AppConfig.get_table_name()
    end
  end
end
