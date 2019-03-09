require "mail"

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      email = Mail::Address.new(value)
      valid = email.domain && email.address == value
      valid &&= email.domain =~ /\./
    rescue
      valid = false
    end
    record.errors[attribute] << (options[:message] || "is invalid") unless valid
  end
end
