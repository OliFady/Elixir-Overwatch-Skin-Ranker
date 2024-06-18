defmodule SkinRank.Characters do
  alias SkinRank.Characters.Character
  alias SkinRank.Repo

  defp read_json do
    path = "#{:code.priv_dir(:skin_rank)}/static/data/overwatch_character_skins.json"

    File.read!(path)
    |> Jason.decode!()
  end

  defp download_image(url, name) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        file_path = "#{:code.priv_dir(:skin_rank)}/static/images/skins/#{name}"
        File.write!(file_path, body)
        {:ok, file_path}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.puts("Failed to download image: HTTP status #{status_code}")
        {:error, :unexpected_status}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Failed to download image: #{reason}")
        {:error, reason}
    end
  end

  def populate_db() do
    read_json()
    |> Enum.map(fn {name, skins} ->
      skins = skins |> Map.get("skins")

      params =
        %{
          name: name,
          skins:
            Enum.map(skins, fn skin ->
              image_result = download_image(skin["image"], "#{name}_#{skin["description"]}.png")

              case image_result do
                {:ok, file_path} ->
                  %{
                    name: skin["description"],
                    image_url:
                      file_path
                      |> Path.relative_to(:code.priv_dir(:skin_rank))
                      |> String.replace_leading("static", ""),
                    event: skin["event"],
                    cost: skin["cost"]
                  }

                {:error, _reason} ->
                  %{
                    name: skin["description"],
                    image_url: nil,
                    event: skin["event"],
                    cost: skin["cost"]
                  }
              end
            end)
        }

      Character.create_changeset(%Character{}, params)
    end)
    |> Enum.each(&SkinRank.Repo.insert!/1)
  end

  def all do
    Repo.all(Character)
    |> Repo.preload(skins: [votes: :skin])
    |> Enum.map(fn character ->
      skins = Enum.sort_by(character.skins, fn skin -> Enum.count(skin.votes) end, :desc)
      Map.put(character, :skins, skins)
    end)
  end

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(SkinRank.PubSub, topic)
  end

  def notify_subscribers({:ok, vote}, topic, event) do
    Phoenix.PubSub.broadcast(SkinRank.PubSub, topic, {__MODULE__, event, vote})
  end

  def notify_subscribers({:error, _reason} = error, _topic, _event), do: error
end
