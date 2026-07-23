class ServerChecksCleanupJob < ApplicationJob
  queue_as :default

  BATCH_SIZE = 1_000

  def perform
    ServerCheck.stale.in_batches(of: BATCH_SIZE, &:delete_all)
  end
end
