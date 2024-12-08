defmodule ExBankingTest do
  use ExUnit.Case

  describe "create_user/1" do
    test "given number as user, should return error" do
      assert ExBanking.create_user(1) == {:error, :wrong_arguments}
    end

    test "given empty string as user, should return error" do
      assert ExBanking.create_user("") == {:error, :wrong_arguments}
    end

    test "given valid string as user, should return ok" do
      assert ExBanking.create_user("user") == :ok
    end
  end
end
