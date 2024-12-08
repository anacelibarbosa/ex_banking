defmodule ExBanking.UsersTest do
  use ExUnit.Case

  alias ExBanking.Users

  describe "create_user/1" do
    test "given same user, should return error" do
      assert Users.create_user("new_user") == :ok
      assert Users.create_user("new_user") == {:error, :user_already_exists}
    end

    test "given valid user, should return ok" do
      assert Users.create_user("valid_user") == :ok
    end
  end
end
