defmodule SkinRankWeb.LandingLive do
  use SkinRankWeb, :live_view

  def mount(_, _params, socket) do
    if connected?(socket), do: SkinRank.Characters.subscribe("votes")

    socket =
      socket
      |> assign(:characters, SkinRank.Characters.all())
      |> assign(:top_skins, SkinRank.Skin.top_10_skins())

    {:ok, socket}
  end

  def handle_event("vote", %{"skin-id" => skin_id}, socket) do
    SkinRank.Skin.new_vote(skin_id)

    socket = socket |> assign(:characters, SkinRank.Characters.all())
    {:noreply, socket}
  end

  def handle_info({SkinRank.Characters, {:new_vote, skin_id}, _}, socket) do
    {:noreply, socket}
  end
end
