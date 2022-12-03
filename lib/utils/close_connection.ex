defmodule Agogo.Utils.CloseConnection do
  def stop(conne) do
    require Logger
    Process.sleep(1000)
    Mongo.Topology.stop(conne)
    Logger.info(["Conexión con la base de datos cerrada."])
  end
end
