defmodule Helpers.Directory do
  @moduledoc """
    Directory helper functions that can be used to interact with files and folders
  """

  @default_dir "./REPO"

  @doc """
    Check if a dir e
  """
  def get_repo_dir do
    @default_dir
  end

  @doc """
    Get the path of the repo where the directory is expected to be
  """
  def get_cloned_repo_dir do
    project_name = String.split(System.get_env("REPO_URL"), "/")
      |> Enum.at(-1)
      |> String.split(".")
      |> Enum.at(0)

      @default_dir <> "/#{project_name}"
  end

  @doc """
    Check if the needed directory exists, initialize
  """
  def init_data() do
    if !File.dir?(get_repo_dir()) do
      File.mkdir(get_repo_dir())
    end

    # we try add the repo after we know the file has been made
    # TODO: Make sure the machine has git installed
    Helpers.Git.clone_repo(System.get_env("REPO_URL"), get_repo_dir())

    # setup file to has logs to
    Helpers.Git.persist_latest_commit()

    # here we run the function to setup all md files
    document_directory_setup()
  end

  @doc """
    This is where we get all the folders and step to find and create one md doc
    We need to get file and remove the rest
  """
  def document_directory_setup do
    :ok
  end
end
