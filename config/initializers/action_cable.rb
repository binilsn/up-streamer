# frozen_string_literal: true

# Handles race conditions where a client sends an unsubscribe command
# for a subscription that was already removed on disconnect.
module ActionCable
  module Connection
    class Subscriptions
      private

      def remove(data)
        logger.info "Unsubscribing from channel: #{data['identifier']}"
        subscription = subscriptions[data["identifier"]]
        remove_subscription(subscription) if subscription
      end
    end
  end
end
