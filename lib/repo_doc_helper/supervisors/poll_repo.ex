defmodule RepoDocHelper.Supervisors.PollRepo do
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

    # process_job(new_state)
    Process.send(self(), :work, [])
    {:ok, new_state}
  end

  # handle message work that will start a job to process
  def handle_info(:work, state) do
    process_job(state)

    # update the job count
    new_job_count = Map.get(state, :job_count) + 1
    new_state = state
      |> Map.put(:job_count, new_job_count )

    attempt_repo_clone(new_state)

    {:noreply, new_state}
  end

  # Process the job interval
  defp process_job(state) do
    %{ :interval => interval } = state
    interval_int = String.to_integer(interval)
    Process.send_after(self(), :work, interval_int*1000)
    {:ok, :noreply}
  end

  # clone repo set for application
  defp attempt_repo_clone(state) do
    # get the file commit
    if Helpers.Git.get_latest_commit() !== Helpers.Git.get_local_commit() do
      Helpers.Directory.init_data()
    else
      IO.inspect("No change require, currently on latest")
    end

    {:ok, state}
  end
end
