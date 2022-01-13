defmodule AC.WebApi.Canvas.Requests.CreateTest do
  use ExUnit.Case, async: true

  alias AC.WebApi.Canvas.Requests.Create

  describe "Create.validate/1" do
    test "returns validation error for missing width and height" do
      params = %{}

      assert %Ecto.Changeset{
               valid?: false,
               changes: %{},
               errors: [
                 width: {"can't be blank", [validation: :required]},
                 height: {"can't be blank", [validation: :required]}
               ]
             } = Create.validate(params)
    end

    test "returns validation error for missing width" do
      params = %{"height" => 3}

      assert %Ecto.Changeset{
               valid?: false,
               changes: %{height: 3},
               errors: [width: {"can't be blank", [validation: :required]}]
             } = Create.validate(params)
    end

    test "returns validation error for missing height" do
      params = %{"width" => 3}

      assert %Ecto.Changeset{
               valid?: false,
               changes: %{width: 3},
               errors: [height: {"can't be blank", [validation: :required]}]
             } = Create.validate(params)
    end

    test "returns validation error when width invalid type" do
      params = %{"width" => "three", "height" => 4}

      assert %Ecto.Changeset{
               valid?: false,
               changes: %{height: 4},
               errors: [width: {"is invalid", [type: :integer, validation: :cast]}]
             } = Create.validate(params)
    end

    test "returns validation error when height invalid type" do
      params = %{"width" => 3, "height" => 4.0}

      assert %Ecto.Changeset{
               valid?: false,
               changes: %{width: 3},
               errors: [height: {"is invalid", [type: :integer, validation: :cast]}]
             } = Create.validate(params)
    end

    test "returns validation error when width not greater than 0" do
      params = %{"width" => -3, "height" => 4}

      assert %Ecto.Changeset{
               valid?: false,
               changes: %{height: 4},
               errors: [
                 width:
                   {"must be greater than %{number}",
                    [validation: :number, kind: :greater_than, number: 0]}
               ]
             } = Create.validate(params)
    end

    test "returns validation error when width not less than or equal to 50" do
      params = %{"width" => 51, "height" => 4}

      assert %Ecto.Changeset{
               valid?: false,
               changes: %{width: 51, height: 4},
               errors: [
                 width:
                   {"must be less than or equal to %{number}",
                    [validation: :number, kind: :less_than_or_equal_to, number: 50]}
               ]
             } = Create.validate(params)
    end

    test "returns validation error when height not less than or equal to 50" do
      params = %{"width" => 3, "height" => 53}

      assert %Ecto.Changeset{
               valid?: false,
               changes: %{width: 3, height: 53},
               errors: [
                 height:
                   {"must be less than or equal to %{number}",
                    [validation: :number, kind: :less_than_or_equal_to, number: 50]}
               ]
             } = Create.validate(params)
    end

    test "returns valid changeset when widht and height less than or equal to 50" do
      params = %{"width" => 3, "height" => 5}
      assert %Ecto.Changeset{valid?: true} = Create.validate(params)
    end
  end
end
