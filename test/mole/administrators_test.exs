defmodule Mole.AdministratorsTest do
  use ExUnit.Case, async: true

  alias Mole.Administrators

  setup do
    [
      aux_name: "shakate",
      default_admins: Application.get_env(:mole, :default_admins)
    ]
  end

  test "the mapset starts with the default administrator", c do
    assert MapSet.equal?(
             Agent.get(Administrators, & &1),
             MapSet.new(c.default_admins)
           )
  end

  test "the agent all/0 gets all default administrators", c do
    assert MapSet.equal?(
             MapSet.new(Administrators.all()),
             MapSet.new(c.default_admins)
           )
  end

  test "the agent is?/1 gets a default administrator", c do
    c.default_admins
    |> List.first()
    |> Administrators.is?()
    |> assert()
  end

  test "adding an administrator is successful", c do
    assert Administrators.add(c.aux_name) == :ok

    assert MapSet.equal?(
             Agent.get(Administrators, & &1),
             MapSet.new([c.aux_name | c.default_admins])
           )

    # revert to original
    :ok = Agent.update(Administrators, &MapSet.delete(&1, c.aux_name))
    # assert that the reversion was successful
    assert Agent.get(Administrators, & &1) == MapSet.new(c.default_admins)
  end

  test "removing an administrator is successful", c do
    # manually add a user by agent functions
    :ok = Agent.update(Administrators, &MapSet.put(&1, c.aux_name))
    # assert that went well
    assert MapSet.equal?(
             Agent.get(Administrators, & &1),
             MapSet.new([c.aux_name | c.default_admins])
           )

    # test the function
    assert Administrators.remove(c.aux_name) == :ok
    # assert that it reverted correctly
    assert MapSet.equal?(
             Agent.get(Administrators, & &1),
             MapSet.new(c.default_admins)
           )
  end
end
