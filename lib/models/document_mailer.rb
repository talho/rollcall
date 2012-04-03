require 'action_controller/deprecated/dispatcher'

module Rollcall
  module DocumentMailer
    # Method is called when a new document is added to the users Rollcall Documents
    #
    # @param document the document object that was added
    # @param user     the user who owns the document
    def rollcall_document_addition(document, user)
      users = document.audience.nil? ? [] : document.audience.recipients.reject{|u| u.roles.length == 1 && u.roles.include?(Role.public)}
      users << document.folder.owner

      bcc users.map(&:formatted_email)
      from DO_NOT_REPLY
      subject %Q{A document has been added to the shared folder "#{document.folder.name}"}
      body :share => document.folder, :document => document, :current_user => user
    end

  end

  ActionController::Dispatcher.to_prepare do
    ::DocumentMailer.send(:include, Rollcall::DocumentMailer)
  end
end
