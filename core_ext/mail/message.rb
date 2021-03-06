require 'mail'

# This is prepended to Mail::Message.
# https://github.com/mikel/mail/blob/master/lib/mail/message.rb
#
module MailMessageExtension

  # This method overrides the original delivery method in order to
  # handle cases where the message cannot be delivered. In those
  # cases, the email adress is marked as 'invalid'.
  #
  # Also make sure to only deliver emails to users with accounts.
  #
  def deliver
    if Ability.new(nil).can? :use, :mail_delivery_account_filter
      return false unless @allow_recipients_without_account || recipient_is_system_address? || recipient_has_user_account?
    end

    if recipient_address.include?('@')
      begin
        Rails.logger.info "Sending mail smtp_envelope_to #{self.smtp_envelope_to.to_s}."
        return super
      rescue Net::SMTPFatalError, Net::SMTPSyntaxError => error
        Rails.logger.debug error
        Rails.logger.warn "smtp-envelope-to field: #{self.smtp_envelope_to.to_s}"
        Rails.logger.warn "to field: #{self.to.to_s}"
        Rails.logger.warn "recognized recipient address (address only!): #{recipient_address}"
        Rails.logger.warn error.message
        recipient_address_needs_review!
        return false
      rescue Net::SMTPServerBusy => error
        Rails.logger.debug error
        Rails.logger.warn "Net::SMTPServerBusy when sending message. Waiting 60 seconds and retrying then ..."
        sleep 60
        retry
      end
    else
      recipient_address_needs_review!
      return false
    end
  end

  def allow_recipients_without_account!
    @allow_recipients_without_account = true
  end

  def recipient_address
    self.smtp_envelope_to.try(:first) || self.to.try(:first)
  end

  def recipient_address_needs_review!
    raise RuntimeError, 'no recipient address' unless recipient_address.present?
    if profile_field = recipient_email_profile_field
      Rails.logger.warn "Adding :needs_review flag to email address #{recipient_address}."
      profile_field.needs_review!
    else
      Rails.logger.warn "Could not find matching email address #{recipient_address} in our database."
    end
  end

  private

  def recipient_email_profile_field
    ProfileFields::Email.where(value: recipient_address).first if recipient_address.present?
  end

  def recipient_has_user_account?
    recipient_address.present? && User.find_by_email(recipient_address).has_account?
  end

  def recipient_is_system_address?
    recipient_address == Setting.support_email
  end

end

Mail::Message.send(:prepend, MailMessageExtension)