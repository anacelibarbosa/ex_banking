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
      assert ExBanking.get_balance("missing", "usd") === {:error, :user_does_not_exist}
    end

    test "given valid params, should return correctly" do
      assert ExBanking.create_user("user_1") == :ok
      assert ExBanking.get_balance("user_1", "usd") == {:ok, 0.00}
    end
  end

  describe "deposit/3" do
    test "given invalid params, with missing user, should return error" do
      assert ExBanking.deposit("missing_1", 0, "usd") == {:error, :user_does_not_exist}
    end

    test "given invalid params, with incorrect order, should return error" do
      assert ExBanking.create_user("user_2") == :ok
      assert ExBanking.deposit("user_2", "usd", 0) == {:error, :wrong_arguments}
    end

    test "given valid params, should return correctly" do
      assert ExBanking.create_user("user_3") == :ok
      assert ExBanking.get_balance("user_3", "usd") === {:ok, 0.00}
      assert ExBanking.deposit("user_3", 1, "usd") === {:ok, 1.00}
    end
  end

  describe "withdraw/3" do
    test "given invalid params, with missing user, should return error" do
      assert ExBanking.withdraw("missing_2", 0, "usd") === {:error, :user_does_not_exist}
    end

    test "given invalid params, with incorrect format, should return error" do
      assert ExBanking.create_user("user_4") == :ok
      assert ExBanking.withdraw("user_4", "usd", "0") === {:error, :wrong_arguments}
    end

    test "given invalid params, with greater amount than balance, should return correctly" do
      assert ExBanking.create_user("user_5") == :ok
      assert ExBanking.get_balance("user_5", "usd") === {:ok, 0.00}
      assert ExBanking.deposit("user_5", 2.125, "usd") === {:ok, 2.13}
      assert ExBanking.withdraw("user_5", 2.135, "usd") == {:error, :not_enough_money}
    end

    test "given valid params, should return correctly" do
      assert ExBanking.create_user("user_6") == :ok
      assert ExBanking.deposit("user_6", 2.123, "usd") === {:ok, 2.12}
      assert ExBanking.withdraw("user_6", 2.124, "usd") === {:ok, 0.00}
    end
  end
end
