defmodule TwitterCloneWeb.TweetComponents do
  use Phoenix.Component

  attr :data, :list, default: []

  def list_tweet(assigns) do
    ~H"""
    <%= for tweet <- @data do %>
      <div class="posts">
        <div class="post border-[1px] border-y-gray-600 border-x-0">
          <div class="flex">
            <div class="image m-4 flex-shrink-0">
              <img class="w-10 h-10 rounded-full" src="assets/images/image.png" />
            </div>
            
            <div class="content my-3 flex-grow">
              <div class="flex items-center">
                <span
                  class="font-bold hover:underline cursor-pointer text-white"
                  style="cursor: pointer;"
                  phx-click="view_post"
                  phx-value-id={tweet.id}
                >
                  <%= tweet.username %>
                </span>
                 <span class="text-gray-500 ml-2"><%= tweet.username %></span>
              </div>
              
              <div class="postimg m-2 ml-0 text-white">
                <%= tweet.desc %> <br /> <img src={tweet.gambar} />
              </div>
              
              <div class="icons flex justify-between mx-4 my-4 text-sm text-gray-600">
                <div class="icon flex items-center justify-center hover:text-blue-500 hover:bg-gray-900 hover:rounded-full p-1 hover:cursor-pointer">
                  <span class="material-symbols-outlined">
                    chat_bubble
                  </span>
                   <%= length(tweet.comments) %>
                </div>
                
                <div class="icon flex items-center justify-center hover:text-green-500 hover:bg-gray-900 hover:rounded-full p-1 hover:cursor-pointer">
                  <span class="material-symbols-outlined">
                    repeat
                  </span>
                  1k
                </div>
                
                <div
                  phx-click="like"
                  phx-value-id={tweet.id}
                  class="icon flex items-center justify-center hover:text-pink-500 hover:bg-gray-900 hover:rounded-full p-1 hover:cursor-pointer"
                >
                  <span class="material-symbols-outlined">
                    Favorite
                  </span>
                   <%= tweet.likes %>
                </div>
                
                <div class="icon flex items-center justify-center hover:text-blue-500 hover:bg-gray-900 hover:rounded-full p-1 hover:cursor-pointer">
                  <span class="material-symbols-outlined">
                    bar_chart
                  </span>
                  1k
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  attr :selected, :map, default: %{}

  def detail_tweet(assigns) do
    ~H"""
    <div class="header flex items-center space-x-2" style="cursor:pointer;" phx-click="back_home">
      <!-- SVG for left arrow icon -->
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-6 w-6"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
      </svg>
      
      <h1 style="font-size:20px; color: white;">Post</h1>
    </div>

    <div class="mt-5" style="width:500px;">
      <div class="bg-gray-900 rounded-lg border border-gray-700 p-4">
        <div class="flex space-x-3">
          <img
            class="w-10 h-10 rounded-full"
            src="assets/images/image.png"
            alt="User Profile Picture"
          />
          <div>
            <h3 class="font-semibold text-white"><%= @selected.username %></h3>
            
            <p class="text-gray-400"><%= @selected.username %></p>
          </div>
        </div>
        
        <p class="mt-3 text-gray-200" style="margin:25px 0;">
          <%= @selected.desc %>
        </p>
         <img src={@selected.gambar} />
      </div>
      <!-- Comment Form -->
      <div class="mt-5 bg-gray-900 rounded-lg border border-gray-700 p-4">
        <form phx-submit="add_komen" phx-value-id={@selected.id} class="flex space-x-3">
          <input
            type="text"
            name="komen"
            placeholder="Add a comment..."
            class="border-gray-600 focus:ring-blue-500 focus:border-blue-500 flex-1 rounded-lg p-2 bg-gray-800 text-white"
          /> <button type="submit" class="bg-blue-500 text-white rounded-lg px-4 py-2">Post</button>
        </form>
      </div>
      <!-- Comments List -->
      <div
        class="mt-5 bg-gray-900 rounded-lg border border-gray-700 p-4"
        style="max-height: 250px; overflow-y: auto;"
      >
        <h3 class="font-semibold text-lg text-white">Comments</h3>
        
        <%= for komen <- @selected.comments do %>
          <hr class="border-gray-700" />
          <div class="divide-y divide-gray-700">
            <div class="py-4 flex space-x-3">
              <img
                class="w-8 h-8 rounded-full"
                src="assets/images/image.png"
                alt="User Profile Picture"
              />
              <div>
                <h4 class="font-semibold text-white">Anonymous</h4>
                
                <p class="text-sm text-gray-400">@anonymous</p>
                
                <p class="mt-1 text-gray-200">
                  <%= komen %>
                </p>
                
                <div class="mt-4 flex justify-around text-gray-400" style="width:400px;">
                  <!-- Icons can be added here if needed -->
                </div>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
