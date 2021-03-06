module Commands
  class SubmitKey
    class << self
      def name
        :submit_key
      end

      def attributes
        {
            usage: 'submit_key',
            description: 'Submit a game key to the store',
            aliases: [:sk]
        }
      end

      def command(event)
        return if event.from_bot?

        if event.server.nil?
          return "Initiate this command in a server"
        else
          event.respond "Check your pms!"
        end
        game_key = GameKey.new(server: event.server.id)
        event.respond "The game submission process will loop until you stop it."
        loop do
          event.user.pm "You can cancel this at any time by saying 'stop'"
          event.user.pm "What game are you submitting?"

          response = nil
          loop do
            response = event.user.await!
            break if response.server.nil?
          end
          if response.message.content == 'stop'
            event.user.pm "Game key submission cancelled"
            break
          end
          game_key.name = response.message.content

          event.user.pm "What's the key?"
          loop do
            response = event.user.await!
            break if response.server.nil?
          end
          if response.message.content == 'stop'
            event.user.pm "Game key submission cancelled"
            break
          end
          game_key.key = response.message.content
          game_key.save
          event.user.pm "Key submitted!"
          event.respond "#{game_key.name} has been added!"
        end
      end
    end
  end
end