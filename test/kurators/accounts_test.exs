defmodule Kurators.AccountsTest do
  use Kurators.DataCase

  alias Kurators.Accounts
  alias Kurators.Accounts.Users

  @valid_attrs %{name: "my account"}

  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Accounts.create_account()

    account
  end

  @valid_attrs %{email: "test@test.com"}

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Users.create_user()

    user
  end

  test "list_accounts/0 returns all accounts" do
    account = account_fixture()
    assert Accounts.list_accounts() == [account]
  end

  test "list_users/0 returns all users" do
    account = account_fixture()
    user = user_fixture(%{accounts_id: account.id})
    assert Users.list_users() == [user]
  end
end
