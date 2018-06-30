ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Mole.Repo, :manual)

Mox.defmock(HTTPoisonMock, for: HTTPoison.Base)
