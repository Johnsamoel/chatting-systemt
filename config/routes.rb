Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Applications
  post '/app/create' => 'chat_groups#create'
  get '/app/find' => 'chat_groups#find_application'
  patch '/app/update' => 'chat_groups#update'
  get '/app/get/:page' => 'chat_groups#find_applications'
  get '/app/chats', to: 'chat_groups#get_chats'

  # Chats
  post '/chats/create' => 'chats#create'
  get '/chats/:chat_id/messages' => 'chats#get_messages'
  patch '/chats/:id/update' => 'chats#update'

  # message
  post '/chat/messages/create' => 'messages#create' 
  get  '/chat/:chat_id/messages/search' => 'messages#search' 
  patch '/chat/:chat_id/messages/update' => 'messages#update'

  # not found
  match '*unmatched_route', to: 'errors#not_found', via: :all

end
