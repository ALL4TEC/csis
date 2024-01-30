# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :authenticate_user!, except: %i[users staff contact]
  before_action :authenticate_user_no_redir!, only: %i[users staff contact]
  before_action :authorize!, only: %i[index users staff contact]
  before_action :set_whodunnit
  before_action :set_group, only: %i[add_user remove_user]
  before_action :set_user, only: %i[add_user remove_user]
  before_action :authorize_group_user!, only: %i[add_user remove_user]
  before_action :set_breadcrumb, only: %i[index]

  include MfaController

  # GET /groups
  def index; end

  # AJAX GET /groups/users
  def users; end

  # AJAX GET /groups/staff
  def staff; end

  # AJAX GET /groups/contact
  def contact; end

  # POST /groups/:id/users/:user_id
  def add_user
    @user.groups << @group
    @user.current_group = @group if @user.current_group.blank?
    redirect_to back_in_history
  end

  # DELETE /groups/:id/users/:user_id
  def remove_user
    UserGroup.find_by(user: @user, group: @group).destroy
    redirect_to back_in_history
  end

  private

  def authorize!
    authorize(Group)
  end

  def set_group
    handle_unscoped do
      @group = policy_scope(Group).find(params[:id])
    end
  end

  def set_user
    handle_unscoped do
      @user = policy_scope(User).find(params[:user_id])
    end
  end

  def authorize_group_user!
    unless GroupPolicy.new(current_user, { group: @group, user: @user })
                      .send(:"#{params[:action]}?")
      raise Pundit::NotAuthorizedError
    end
  end

  def set_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('groups.section_title'), :groups_url
  end
end
