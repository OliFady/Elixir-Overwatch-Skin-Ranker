defmodule SkinRank.Skins.Skin do
  use Ecto.Schema

  schema "skins" do
    field :name, :string
    field :image_url, :string
    field :event, :string
    field :cost, :string
    belongs_to :character, SkinRank.Characters.Character
    has_many :votes, SkinRank.Skins.Vote
  end

  def create_changeset(skin, atrrs) do
    skin |> Ecto.Changeset.cast(atrrs, [:name, :image_url, :event, :cost])
  end
end
