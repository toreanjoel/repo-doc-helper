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
    IO.inspect("Prepare directory creation")
    if !File.dir?(get_repo_dir()) do
      File.mkdir(get_repo_dir())
    end

    # we try add the repo after we know the file has been made
    # TODO: Make sure the machine has git installed
    IO.inspect("Get relevant project repo cloned")
    Helpers.Git.clone_repo(System.get_env("REPO_URL"), get_repo_dir())

    # setup file to has logs to
    IO.inspect("Store last commit hash for reference")
    Helpers.Git.persist_latest_commit()

    # Remove the assets and .git files as we wont be committing
    # TODO: This causds slow or race conditions writing wrong data to file
    System.cmd("sh", ["-c", "cd #{get_cloned_repo_dir()} && rm -r .gitbook"])

    # here we run the function to setup all md files
    # NOTE: I pass the path as this is used recursively so makes sense to
    # dont need to check if passed or have fallbacks
    IO.inspect("Flatten the directory to remove nested folders")
    # flatten_dir(get_cloned_repo_dir())

    # Remove non .md files
    # TODO: Check if we need to change this later to support other types?
    IO.inspect("Removing non markdown files as only .md is relevant in this case")
    # md_filter()

    # the end of the init execution - success or fail
    IO.inspect("Init execution end")
  end

  @doc """
    Flatten the entire project structure so we can have one directory with the data
  """
  def flatten_dir(path) do
    # TODO: Dont do anything to the .git files - this moves or removes and log for remote wont work
    File.ls!(path)
    |> Enum.each(fn file_or_dir ->
      full_path = Path.join(path, file_or_dir)

      if File.dir?(full_path) do
        flatten_dir(full_path)
        File.rm_rf!(full_path)
      else
        File.rename!(full_path, get_cloned_repo_dir() <> "/#{file_or_dir}")
      end
    end)
  end

  @doc """
    Look for markdown files only and remove the rest
  """
  def md_filter() do
     File.ls!(get_cloned_repo_dir())
      |> Enum.each(fn file ->
        extension = String.split(file, ".") |> Enum.at(-1)
        if extension !== "md" do
          File.rm(get_cloned_repo_dir() <> "/#{file}")
        end
      end)
  end
end
