defmodule Agogo.Router do
  @moduledoc """
  Las rutas de dotor
  """
  use Plug.Router

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  import Plug.Conn
  plug(:match)
  require Logger
  plug(CORSPlug)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/get/captcha" do
    # vamos a ejecutar nuestro python script
    # abc123
    random_word = for _ <- 1..6, into: "", do: <<Enum.random('012345689abcdefg')>>
    ip = Agogo.Utils.GetIp.get(conn)
    # ejecuta el script
    :os.cmd('python3 lib/router/scripts/c.py --i #{ip} -w #{random_word} ; mv *.png lib/images')

    # Ahora tenemos que guardar en la ip (Que va a ser nuestro identificador) y la palabra que se genero para ver si el usuario resolvio el captcha o no
    {:ok, conne} = Mongo.start_link(url: "mongodb://localhost:27017/agogo")

    data_to_insert = %{
      "word" => random_word,
      "ip" => ip,
      "solved" => false
    }

    Mongo.insert_one(conne, ip, data_to_insert)
    # manda la imagen
    Logger.info(data_to_insert)
    send_file(conn, 200, "lib/images/#{ip}.png")
    # Cerramos la conexión
    Agogo.Utils.CloseConnection.stop(conne)
  end

  post "/post/captcha" do
    ip = Agogo.Utils.GetIp.get(conn)

    word =
      case conn.body_params do
        %{"word" => w} -> w
        _ -> ""
      end

    Logger.info([word])
    # Devolver un valor booleano si paso el capcha
    # -> true: valido
    # -> false: invalido
    {:ok, conne} = Mongo.start_link(url: "mongodb://localhost:27017/agogo")

    # busca esa monda
    cursor = Mongo.find_one(conne, ip, %{}, sort: %{_id: -1})
    # checa si la palabra del captcha es la que esta en la base de datos
    Logger.info([word, " ??? ", cursor["word"]])

    if word == cursor["word"] do
      # Si esta correcta la palabra

      # cambiar a solved => true
      # Se borra todo
      Mongo.drop_collection(conne, "#{ip}")
      # Se vuelve a crear esa monda pero esta vez con true
      data_to_insert = %{
        "word" => word,
        "ip" => ip,
        "solved" => true
      }

      ## insert the data
      Mongo.insert_one(conne, ip, data_to_insert)
      # Stop cooanfjlfl...
      send_resp(
        conn |> put_resp_content_type("application/json"),
        200,
        Jason.encode!("ok")
      )

      # Cerrar la conexión
      Agogo.Utils.CloseConnection.stop(conne)
    else
      send_resp(
        conn |> put_resp_content_type("application/json"),
        200,
        Jason.encode!("no es correcto el captcha")
      )
    end
  end

  # Por si la ruta no existe
  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
