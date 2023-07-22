defmodule RepoDocHelper.Supervisors.RepoFetch do
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

    process_job(new_state)
    {:ok, new_state}
  end

  # handle message work that will start a job to process
  def handle_info(:work, state) do
    process_job(state)

    # update the job count
    new_job_count = Map.get(state, :job_count) + 1
    new_state = state
      |> Map.put(:job_count, new_job_count )

    # terminate if the increment made it more than 5
    # not important but using it so we can make a new process
    # if (state.job_count == 5) do
    #   Process.exit(self(), :normal)
    # end
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
  IO.inspect("reclone attempt")
  defp attempt_repo_clone(state) do
    # we need to read from a file and get the last saved timestamp
    # compare against latest commit and check if diff
    # do a git pull and run the md setup again
    # might need to remove the folder and do setup again
    {:ok, state}
  end
end
