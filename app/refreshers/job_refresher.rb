# frozen_string_literal: true

class JobRefresher
  extend CableReady::Broadcaster

  JOBS_LIST_SEL = '#jobs_list'
  RUNNING_JOBS_SEL = '#running-jobs'
  JOBS_COUNTER_SEL = '#jobs_counter'

  class << self
    # Reset #jobs_list content with 'jobs/list'
    # Try not to use this method as treatment will increase as with content size
    # def refresh_list(_job)
    #   possible_viewers = User.with_role(:super_admin)
    #   possible_viewers.each do |user|
    #     cable_ready[UsersChannel].inner_html(
    #       selector: '#jobs_list',
    #       html: ApplicationController.render(
    #         partial: 'jobs/list', locals: { jobs: Job.all }
    #       )
    #     ).broadcast_to(user)
    #   end
    # end

    # Add new job to '#jobs_list' top
    # Broadcast to all (connected...) super_admins, so no risk to add to an unallowed user
    def add_to_list(job)
      possible_viewers = User.with_role(:super_admin)
      possible_viewers.each do |user|
        cable_ready[JobsListChannel].prepend(
          selector: JOBS_LIST_SEL,
          html: ApplicationController.render(job)
        ).broadcast_to(user)
      end
    end

    # Reset #running-jobs content with 'jobs/light_list'
    # As there is only 5 possible jobs, we update the entire list content
    # for specified user
    def refresh_user_running_jobs(user, job)
      action = job.status.in?(%w[completed error]) ? :add : :remove
      cable_ready[UsersChannel].send(
        :"#{action}_css_class", name: 'd-none', selector: JOBS_COUNTER_SEL
      ).inner_html(
        selector: RUNNING_JOBS_SEL,
        html: ApplicationController.render(
          partial: 'jobs/light_list', locals: { jobs: user.subscribed_jobs.limit(5) }
        )
      ).broadcast_to(user)
    end

    # Morph a job, here only in list, but could also include resource channels
    # cable_ready[JobsChannel].morph(
    #  selector: dom_id(job),
    #  html: ApplicationController.render(partials: 'jobs/job_detail' , job: job)
    # ).broadcast_to(job)
    def refresh(job)
      possible_viewers = User.with_role(:super_admin)
      possible_viewers.each do |user|
        # For show/edit visualisation
        cable_ready[JobsListChannel].morph(
          selector: dom_id(job),
          html: ApplicationController.render(job)
        ).broadcast_to(user)
      end
    end
  end
end
