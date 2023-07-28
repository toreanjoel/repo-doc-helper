defmodule Helpers.Python do
  @moduledoc """
    The python helper methods to interact with the system assigned python scripts
  """

  # the path to the python scripts
  @main_py_path File.cwd! <> "/lib/python"
  @python3 "python3" # python cmd function - might need fiddling as its per env

  @doc """
    Execute a script by passing the script name along with list of args
  """
  def execute(script, query) do
    {result, _} = System.cmd(@python3, [@main_py_path <> "/#{script}.py" | [query, System.get_env("OPEN_AI_KEY")]])
    resp = case result do
      "" -> "Something went wrong, make sure the model dataset exists and can be run against"
      _ -> result |> String.trim()
    end
    {:result, resp}
  end

  @doc """
    Return the list of all the scripts available
  """
  def list_scripts do
    {:ok,
      File.ls!(@main_py_path)
        |> Enum.filter(fn item ->
          String.split(item, ".") |> Enum.at(1) == "py"
        end)
    }
  end
end
