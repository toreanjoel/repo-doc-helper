defmodule Helpers.Utils do
  @moduledoc """
    Basic utility functions that can be used across the application to help with functional patterns being done
  """

  @doc """
    A formatted response to send to the client - used as a API structure format
  """
  def http_resp(code, success, data \\ %{}) do
    %{
      "success" => success,
      "code" => code,
      "result" => data
    }
  end
end
