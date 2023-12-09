# config/initializers/scheduler.rb

require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '1h' do
  puts 'Running task to count and update chats per application...'

  Application.find_each do |application|
    chats_count = Chat.where(application_id: application.id).count
    application.update(chats_count: chats_count)
  end

  puts 'Chats count per application updated successfully.'
end

scheduler.every '1h' do
    puts 'Running task to count and update messages per chat...'
  
    Chat.find_each do |chat|
      messages_count = chat.messages.count
      chat.update(messages_count: messages_count)
    end
  
    puts 'Messages count per chat updated successfully.'
end
