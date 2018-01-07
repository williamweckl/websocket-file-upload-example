defmodule FileUploadWeb.UploadChannel do
  use FileUploadWeb, :channel
  alias FileUploadWeb.FileUploader

  def join("upload:new", _, socket) do
    {:ok, socket}
  end

  def handle_in("upload:file", params, socket) do
    IO.inspect "params"
    IO.inspect params

    start_range = Map.get(params, "start_range")
    end_range = Map.get(params, "end_range")

    decoded = params
    |> keys_to_atoms()
    |> decode_binary()

    scope = %{start_range: start_range, end_range: end_range}
    {decoded, scope} |> FileUploader.store()

    {:noreply, socket}
  end

  defp keys_to_atoms(params) do
    Map.new(params, fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp decode_binary(params) do
    Map.put(params, :binary, Base.decode64!(params.binary))
  end
end