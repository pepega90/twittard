defmodule TwitterCloneWeb.TwitterCloneLive.Index do
  use TwitterCloneWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @selected == nil do %>
      <div class="second w-full border-[1px] border-x-gray-600 border-y-black ">
        <div class="top flex p-3 sticky top-0 bg-black backdrop-blur-3xl opacity-80">
          <div class="absolute w-16 h-1 rounded-full bg-blue-500 bottom-0 left-[19%] z-10"></div>
          
          <div class="left bg-red-3001 w-1/2 flex justify-center font-bold text-lg">For You</div>
          
          <div class="right bg-green-3001 w-1/2 flex justify-center font-bold text-lg">Following</div>
          
          <div class="settings mx-2">
            <span class="material-symbols-outlined">
              settings
            </span>
          </div>
        </div>
        
        <div class="h-[1px] w-full bg-gray-700"></div>
        
        <div class="whatishapp flex gap-4 my-3">
          <div class="img m-2 w-16">
            <img
              src="https://pbs.twimg.com/profile_images/1559612133158973441/KrLc8L0S_normal.jpg"
              alt=""
            />
          </div>
          
          <div class="w-full">
            <form phx-submit="add" phx-change="change">
              <input
                class="w-full h-7 my-2 text-xl bg-black outline-none text-white"
                type="text"
                name="tweet"
                placeholder="What is happening?!"
              /> <.live_file_input upload={@uploads.image} />
              <%= for entry <- @uploads.image.entries do %>
                <.live_img_preview width="300" height="300" entry={entry} />
              <% end %>
            </form>
            
            <div class="text-blue-400 flex items-center gap-1 w-full my-4">
              <span class="material-symbols-outlined ">
                globe_asia
              </span>
               <span class="font-bold">Everyone can reply</span>
            </div>
            
            <div class="w-[90%] h-[0.2px] bg-gray-700 my-3"></div>
            
            <div class="flex justify-between">
              <div class="blueicons flex gap-10 text-blue-400 items-center">
                <span class="material-symbols-outlined cursor-pointer">
                  image
                </span>
                
                <span class="material-symbols-outlined cursor-pointer">
                  gif
                </span>
                
                <span class="material-symbols-outlined cursor-pointer">
                  ballot
                </span>
                
                <span class="material-symbols-outlined cursor-pointer">
                  sentiment_satisfied
                </span>
                
                <span class="material-symbols-outlined cursor-pointer">
                  calendar_month
                </span>
                
                <span class="material-symbols-outlined cursor-pointer">
                  pin_drop
                </span>
              </div>
              
              <div class="postbtn">
                <button class="bg-[#1d9bf0] px-6 mx-5 text-sm rounded-full py-2 text-white font-bold">
                  Post
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
       <.list_tweet data={@tweets} />
    <% else %>
      <.detail_tweet selected={@selected} />
    <% end %>
    """
  end

  defmodule Tweet do
    defstruct [:id, :desc, :likes, :gambar, :username, :comments]
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: TwitterCloneWeb.Endpoint.subscribe("tweet")

    tweet_seed = [
      %Tweet{
        id: 1,
        desc:
          "Embarking on a new journey today! 🌅 Sometimes, the smallest step in the right direction ends up being the biggest step of your life. #NewBeginnings #AdventureAwaits",
        likes: 152,
        gambar: "",
        comments: [],
        username: "@DawnChaser"
      },
      %Tweet{
        id: 2,
        desc:
          "Planted my 100th tree today! 🌳 Let's make the world greener, one tree at a time. Join the movement! #GoGreen #PlantATree",
        likes: 307,
        gambar: "",
        comments: [],
        username: "@EcoWarrior"
      },
      %Tweet{
        id: 3,
        desc:
          "Caught a glimpse of the Milky Way last night. It's moments like these that remind us how vast the universe is. 🌌 #AstronomyLovers #StarryNight",
        likes: 450,
        gambar: "",
        comments: [],
        username: "@StarGazer"
      }
    ]

    {:ok,
     socket
     |> assign(tweets: tweet_seed, selected: nil)
     |> allow_upload(:image, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
  end

  @impl true
  def handle_event("change", _params, socket), do: {:noreply, socket}
  def handle_event("back_home", _params, socket), do: {:noreply, socket |> assign(selected: nil)}

  def handle_event("add", %{"tweet" => tweet} = _params, %{assigns: %{tweets: tweets}} = socket) do
    image =
      consume_uploaded_entries(socket, :image, fn meta, entry ->
        filename = "#{entry.uuid}#{Path.extname(entry.client_name)}"
        dest = Path.join(TwitterCloneWeb.uploads_dir(), filename)

        File.cp!(meta.path, dest)

        {:ok, ~p"/uploads/#{filename}"}
      end)

    case image do
      [gambar] ->
        new_tweet = %Tweet{
          id: length(tweets) + 1,
          desc: tweet,
          likes: 0,
          gambar: gambar,
          username: "anonim",
          comments: []
        }

        TwitterCloneWeb.Endpoint.broadcast("tweet", "new", new_tweet)
        {:noreply, socket}

      [] ->
        new_tweet = %Tweet{
          id: length(tweets) + 1,
          desc: tweet,
          likes: 0,
          gambar: "",
          username: "anonim",
          comments: []
        }

        TwitterCloneWeb.Endpoint.broadcast("tweet", "new", new_tweet)
        {:noreply, socket}
    end
  end

  def handle_event("upload_gambar", _params, socket) do
    "upload" |> IO.inspect()
    {:noreply, socket}
  end

  def handle_event("add_komen", %{"komen" => ""}, socket), do: {:noreply, socket}

  def handle_event(
        "add_komen",
        %{"komen" => komen} = _params,
        %{assigns: %{selected: post, tweets: tweets}} = socket
      ) do
    update_post = post |> Map.update!(:comments, fn e -> [komen | e] end)
    idx_tweet = tweets |> Enum.find_index(fn e -> e.id == update_post.id end)
    update_tweets = tweets |> List.replace_at(idx_tweet, update_post)

    TwitterCloneWeb.Endpoint.broadcast("tweet", "broad_komen", update_post)

    {:noreply, socket |> assign(selected: update_post, tweets: update_tweets)}
  end

  def handle_event("view_post", %{"id" => id} = _params, %{assigns: %{tweets: tweets}} = socket) do
    post = tweets |> Enum.find(fn e -> e.id == id |> String.to_integer() end)
    {:noreply, socket |> assign(selected: post)}
  end

  def handle_event(
        "like",
        %{"id" => _id, "detail" => "detail_post"} = _params,
        %{
          assigns: %{selected: selected_tweet}
        } = socket
      ) do
    updated_tweet =
      selected_tweet |> Map.update!(:likes, fn e -> e + 1 end)

    {:noreply, socket |> assign(selected: updated_tweet)}
  end

  def handle_event("like", %{"id" => id} = _params, socket) do
    TwitterCloneWeb.Endpoint.broadcast("tweet", "love", String.to_integer(id))
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{topic: "tweet", event: "broad_komen", payload: payload}, socket),
    do: {:noreply, socket |> assign(selected: payload)}

  def handle_info(
        %{topic: "tweet", event: "new", payload: payload},
        %{assigns: %{tweets: tweets}} = socket
      ),
      do: {:noreply, socket |> assign(tweets: [payload | tweets])}

  def handle_info(
        %{topic: "tweet", event: "love", payload: idParam},
        %{assigns: %{tweets: tweets}} = socket
      ) do
    idx_tweet = tweets |> Enum.find_index(fn e -> e.id == idParam end)

    find_tweet =
      tweets |> Enum.find(fn e -> e.id == idParam end) |> Map.update!(:likes, fn e -> e + 1 end)

    update_tweets = tweets |> List.replace_at(idx_tweet, find_tweet)

    {:noreply, socket |> assign(tweets: update_tweets)}
  end
end
