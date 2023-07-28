defmodule RepoDocHelper.Server.Repo do
  @moduledoc """
    The repo fetching scheduler that will run and run commands at an interval
  """
  use GenServer

  # Client
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  # Server
  def init(state) do
    # start service here that will run on interval
    new_state = state
      |> Map.put(:job_count, 0)
      |> Map.put(:repo_ready, File.dir?(Helpers.Directory.get_cloned_repo_dir()))

    {:ok, new_state}
  end

  # handle message work that will start a job to process
  def handle_info(:initialize, state) do
    # update the job count
    new_job_count = Map.get(state, :job_count) + 1
    new_state = state
      |> Map.put(:job_count, new_job_count )

    # TODO: The response here should determine the status toggle for the state
    attempt_repo_clone(new_state)

    {:noreply, new_state}
  end

  # clone repo set for application
  defp attempt_repo_clone(state) do
    Helpers.Directory.init_data()
    {:ok, state}
  end
end
