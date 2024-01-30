# frozen_string_literal: true

# Job destroying everything passed as argument
class DestructorJob < ApplicationKubeJob
  def perform(creator, element)
    receivers = []
    if element.respond_to?(:teams)
      receivers = element.teams.flat_map(&:staffs).uniq
    elsif element.respond_to?(:team)
      receivers = element.team.staffs.uniq
    end
    job_h = {
      creator: creator,
      progress_steps: 2,
      subscribers: receivers
    }
    handle_perform(job_h) do |job|
      logger.debug "#{self.class} started for: #{element}"
      job.update!(status: :destroying)
      element.destroy!
      logger.debug "#{self.class}: OK"
      job.update!(status: :completed)
    end
  end
end
