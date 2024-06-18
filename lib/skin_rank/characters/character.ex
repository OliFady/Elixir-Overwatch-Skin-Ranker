defmodule SkinRank.Characters.Character do
  use Ecto.Schema

  schema "characters" do
    field :name, :string
    has_many :skins, SkinRank.Skins.Skin
  end

  def create_changeset(character, attrs) do
    character
    |> Ecto.Changeset.cast(attrs, [:name])
    |> Ecto.Changeset.cast_assoc(:skins, with: &SkinRank.Skins.Skin.create_changeset/2)
  end
end
