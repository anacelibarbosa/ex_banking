defmodule ExBankingTest do
  use ExUnit.Case

  describe "create_user/1" do
    test "given number as user, should return error" do
      assert ExBanking.create_user(1) == {:error, :wrong_arguments}
    end

    test "given empty string as user, should return error" do
      assert ExBanking.create_user("") == {:error, :wrong_arguments}
    end

    test "given same user, should return error" do
      assert ExBanking.create_user("same_user") == :ok
      assert ExBanking.create_user("same_user") == {:error, :user_already_exists}
    end

    test "given valid string as user, should return ok" do
      assert ExBanking.create_user("user") == :ok
    end
  end

  describe "get_balance/2" do
    test "given invalid params, with missing user, should return error" do
      assert ExBanking.get_balance("missing", "usd") == {:error, :user_does_not_exist}
    end

    test "given valid params, should return correctly" do
      assert ExBanking.create_user("user_1") == :ok
      assert ExBanking.get_balance("user_1", "usd") == {:ok, 0.00}
    end
  end
end
