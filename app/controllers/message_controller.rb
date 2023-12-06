class MessagesController < ActionController::API
    def create
        @chat = Chat.find_by(application_id: params[:application_id], number: params[:chat_number])
        @message = @chat.messages.create(body: params[:body], number: @chat.messages_count + 1)
        render json: { message_number: @message.number }
      end
    
      def search
        @chat = Chat.find_by(application_id: params[:application_id], number: params[:chat_number])
        @messages = @chat.messages.search(params[:query])
        render json: @messages
      end
end
