# frozen_string_literal: true

class ContactsController < UsersController
  def create
    handle_params
    super
  end

  private

  # TODO: MOVE in dedicated params handler?

  def handle_params
    return if staff_signed_in?

    if current_user.id == params[:id]
      adminrole = Role.of_contacts.where(name: 'contact_admin')
      params[:contact][:role_ids].push(adminrole.first.id)
      params[:contact][:contact_client_ids] += current_user.contact_clients.ids
    else
      unless contact_params[:contact_client_ids].drop(1).any? # Dropping empty string
        flash[:alert] = t('contacts.notices.teams_selection')
        return false
      end

      # Re-push initial clients of contact being modified
      if @contact.present?
        (@contact.contact_clients - current_user.contact_clients).each do |client|
          params[:contact][:contact_client_ids].push(client.id)
        end
      end
    end
  end

  def contact_in_perimeter?
    return true if staff_signed_in?

    @text_flash = t('contacts.notices.auto_deletion') if current_user.email == @contact.email

    # This contact is also in another administrator perimeter.
    if (@contact.contact_clients - current_user.contact_clients).present?
      @contact.contact_clients = @contact.contact_clients - current_user.contact_clients
      @contact.save
      @text_flash = t('contacts.notices.outside_perimeter')
      return false
    end

    true
  end

  def contact_params
    params.require(:contact).permit(policy(:contact).permitted_attributes)
  end
end
