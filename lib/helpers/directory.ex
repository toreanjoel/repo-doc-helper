defmodule Helpers.Directory do
  @moduledoc """
    Directory helper functions that can be used to interact with files and folders
  """

  @doc_dir "./_DOCUMENTS"
  @model_data_dir "./_MODEL_DATA"

  @doc """
    Initial repo directory
  """
  def get_repo_dir do
    @doc_dir
  end

  @doc """
    Model data directory
  """
  def get_model_data_dir do
    @model_data_dir
  end

  @doc """
    Get the path of the repo where the directory is expected to be
  """
  def get_cloned_repo_dir do
    project_name = String.split(System.get_env("REPO_URL"), "/")
      |> Enum.at(-1)
      |> String.split(".")
      |> Enum.at(0)

      @doc_dir <> "/#{project_name}"
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

    # Remove the assets and .git files as we wont be committing
    # TODO: This causds slow or race conditions writing wrong data to file
    System.cmd("sh", ["-c", "cd #{get_cloned_repo_dir()} && rm -r .gitbook"])

    # here we run the function to setup all md files
    # NOTE: I pass the path as this is used recursively so makes sense to
    # dont need to check if passed or have fallbacks
    IO.inspect("Flatten the directory to remove nested folders")
    flatten_dir(get_cloned_repo_dir())

    # Remove non .md files
    # TODO: Check if we need to change this later to support other types?
    IO.inspect("Removing non markdown files as only .md is relevant in this case")
    md_filter()

    # Generate model data doc
    generate_model_doc()

    # TODO: Vectorize the data and store
    # TODO: OPEN AI w/ Python and langchain
    # TODO: Docs around external db, nx for vectors in elixir, custom LLM save costs, split sections and not 1 doc
    # TODO: API
    # TODO: Python helpers to call
    # TODO: Docker setup and install
    # TODO: API to get status of a app pulling, removing of repo etc (setup data)
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
        File.rename!(full_path, @doc_dir <> "/#{file_or_dir}")
      end
    end)
  end

  @doc """
    Look for markdown files only and remove the rest
  """
  def md_filter() do
     File.ls!(get_repo_dir())
      |> Enum.each(fn file ->
        extension = String.split(file, ".") |> Enum.at(-1)
        if extension !== "md" do
          File.rm(get_repo_dir() <> "/#{file}")
        end
      end)
  end

  @doc """
    Take the data in the documents to create and write to 1 document
  """
  def generate_model_doc() do
    write_files_to_one(File.ls!(get_repo_dir())
      |> Enum.map(fn file_dir ->
          if !File.dir?(file_dir) do
            get_repo_dir() <> "/" <> file_dir
          end
      end))
  end

  @doc """
    Create the file and write to the data file all the data of the passed files
  """
  def write_files_to_one(input_files) do
    # create the file then write to it
    model_data_path = get_model_data_dir() <> "/model_data.txt"
    case File.exists?(model_data_path) do
      false ->
        System.cmd("sh", ["-c", "mkdir #{get_model_data_dir()} && cd #{get_model_data_dir()} && touch model_data.txt"])
        {:ok, "Path created"}
      _ -> {:ok, model_data_path}
    end

    # we open the file and write to it
    File.open(model_data_path, [:write], fn output ->
      for file <- input_files do
        case File.read(file) do
          {:ok, content} ->
            IO.binwrite(output, content)
            IO.binwrite(output, "\n")  # Add a newline after each file's content.
          {:error, reason} -> IO.puts("Error reading #{file}: #{reason}")
        end
      end
    end)
  end
end
