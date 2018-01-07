defmodule FileUploadWeb.FileUploader do
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  # use Arc.Ecto.Definition

  def __storage, do: Arc.Storage.Local

  @versions [:processed]
  @extension_whitelist ~w(.jpg .jpeg .gif .png .mp4 .webm .mkv)

  # TODO: VALIDAR SE DURATION NÃO PASSOU DO LIMITE

  # ex 00:00:02
  defp convert_seconds_to_ffmpeg_time(seconds) do
    Timex.parse!("#{seconds}", "%s", :strftime) |> Timex.format!("%H:%M:%S", :strftime)
  end

  # Video duration cut
  def transform(:processed, {_file, scope}) do
    IO.inspect "entrou aki processed"
    IO.inspect scope
    IO.inspect scope.end_range
    IO.inspect scope.start_range
    IO.inspect String.to_integer(scope.end_range)
    IO.inspect String.to_integer(scope.start_range)

    start = scope.start_range
      |> convert_seconds_to_ffmpeg_time

    duration = String.to_integer(scope.end_range) - String.to_integer(scope.start_range)
    duration = duration
      |> convert_seconds_to_ffmpeg_time

    {:ffmpeg, fn(input, output) ->
      "-i #{input} -f webm -ss #{start} -t #{duration} #{output}"
    end, :webm}
  end

  # ffmpeg -i movie.mp4 -ss 00:00:03 -t 00:00:08 -async 1 cut.mp4

  # Video thumb
  # def transform(:thumb, _) do
  #   IO.inspect "entrou aki thumb"

  #   {:ffmpeg, fn(input, output) -> "-i #{input} -f jpg a#{output}" end, :jpg}
  # end

  # # Video duration cut
  # def transform(:duration_cut, _) do
  #   IO.inspect "entrou aki"

  #   {:ffmpeg, fn(input, output) ->
  #     "-i #{input} -ss 00:00:02 -t 00:00:04 #{output}"
  #   end, :mp4}
  # end

  # ffmpeg -i movie.mp4 -ss 00:00:03 -t 00:00:08 -async 1 cut.mp4

  # Whitelist file extensions:
  # def validate({file, _}) do
  #   ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  # end

  # Define a thumbnail transformation:
  # def transform(:thumb, _) do
  #   {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  # end

  # Override the persisted filenames:
  def filename(version, {file, _scope}) do
    "#{file.file_name}-#{version}"
  end

  # Override the storage directory:
  # def storage_dir(version, {file, scope}) do
  #   "uploads/user/avatars/#{scope.id}"
  # end
  def storage_dir(version, {file, scope}) do
    "uploads"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: Plug.MIME.path(file.file_name)]
  # end
end
