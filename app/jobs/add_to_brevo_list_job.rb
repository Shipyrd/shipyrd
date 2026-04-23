class AddToBrevoListJob < ApplicationJob
  PRODUCT_UPDATES_LIST_ID = 3

  def perform(user_id)
    user = User.find(user_id)

    api = Brevo::ContactsApi.new
    contact = Brevo::CreateContact.new
    contact.email = user.email
    contact.list_ids = [PRODUCT_UPDATES_LIST_ID]
    contact.update_enabled = true
    api.create_contact(contact)
  end
end
