defmodule Helpers.Git do
  @moduledoc """
    Helper functions for git, assuming its installed on the machine
  """

  @doc """
    Get the commit history of the current branch
  """
  def log(path) do
    {data, _} = System.cmd("sh", ["-c", "cd #{path} && git log"])
    data
  end

  @doc """
    Clone a repo to a path
  """
  def clone_repo(url, path) do
    System.cmd("sh", ["-c", "cd #{path} && git clone #{url}"])
  end

  @doc """
    Here we need to get the logs and check the latest commit timestamp.
    Save the commit in a file? so we can compare when server runs to check
    if we need to pull it down
  """
  def persist_latest_commit() do
    logs =
      log(Helpers.Directory.get_cloned_repo_dir)
        |> String.split("\n")
        |> Enum.at(0) # gets the commit indice
        |> String.split(" ") # remove the string "commit"
        |> Enum.at(1) # we get the commit hash only

    # write logs to a file, we can hash the files?
    File.write(Helpers.Directory.get_repo_dir() <> "/latest_commit.txt", logs)
  end
end
