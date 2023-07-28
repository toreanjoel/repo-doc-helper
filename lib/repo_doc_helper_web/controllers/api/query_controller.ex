defmodule RepoDocHelperWeb.Api.QueryController do
  @moduledoc """
    The controller route functions that we will use for setup and query against the data
  """

  import Plug.Conn
  use RepoDocHelperWeb, :controller
  alias Helpers.{Utils,Python}

  # variables
  @query_prop "ask"

  # server codes
  @code_500 500
  @code_500 500
  @code_200 200
  @code_204 204
  @code_400 400

  @doc """
    Initialize the data from the path set in env variables for the AI to be able to query against
  """
  def init_data(conn, _params) do
    # Init the server that we can then call against
    {_status, pid} = RepoDocHelper.Server.Repo.start_link(%{})
    # Call initialize - async so we can just return
    # TODO: Look into the function in the process so we can figure out the responses and state based on success/fail
    Process.send(pid, :initialize, [])
    return(conn, @code_200, Utils.http_resp(@code_204, true, "The data is being initialized..."))
  end

  @doc """
    Check the status of the dataset directory and if it exists with data
  """
  def status(conn, _params) do
    model_location = File.cwd! <> "/_MODEL_DATA"
    # check if the directory exists
    if File.dir?(model_location) do
      # check if the file exists
      has_dataset = (File.ls!(model_location) |> Enum.member?("model_data.txt"))
      case has_dataset do
        true ->  return(conn, @code_200, Utils.http_resp(@code_200, true, "Dataset exists, to query run a \/query (POST)"))
        _ -> return(conn, @code_400, Utils.http_resp(@code_400, false, "Dataset does not exist yet. Run /initialize (POST) or wait if already executed"))
      end
    else
      return(conn, @code_400, Utils.http_resp(@code_400, false, "Dataset does not exist yet. Run /initialize (POST) or wait if already executed"))
    end

  end

  @doc """
    Query against the initialized dataset
  """
  def query(conn, params) do
    # check the structure basic - we ignore other properties
    case Map.has_key?(params, @query_prop) do
      true ->
        # we extract the query
        %{ @query_prop => query } = params

        # we need to query the server that is doing teh data init to make sure if all is good
        # TODO: Incase we want to keep track of the process state that was started
        # {_, pid, _, _} = :sys.get_status(__MODULE__)

        # implement the query against the dataset
        {_status, resp} = Python.execute(query)
        return(conn, @code_200, Utils.http_resp(@code_200, true, resp))

      _ -> return(conn, @code_400, Utils.http_resp(@code_400, false,
        "There was an error, make sure the payload has a property \'ask\' when querying"))
    end
  end

  # JSON returned response helper method for the controller functions
  defp return(conn, status, data) do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Jason.encode!(data))
  end
end
