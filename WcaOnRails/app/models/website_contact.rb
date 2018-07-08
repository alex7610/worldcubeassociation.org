# frozen_string_literal: true

class WebsiteContact < ContactForm
  attribute :message, validate: true

  validates :inquiry, presence: true
  validates :competition_id, presence: true, if: -> { inquiry == 'competition' }

  attr_accessor :inquiry
  attr_accessor :competition_id

  # Override the `to_mail` validation, to show errors for `inquiry` instead.
  def validate_to_email
    super
    if errors[:to_email].any?
      errors.add(:inquiry, I18n.t('common.errors.invalid'))
      errors.delete(:to_email)
    end
  end

  def to_email
    if inquiry == "competition"
      Competition.find_by_id(competition_id)&.managers&.map(&:email)
    else
      "contact@worldcubeassociation.org"
    end
  end

  def subject
    topic = case inquiry
            when "competition" then "Comment for #{Competition.find_by_id(competition_id)&.name}"
            when "competitions_in_general" then "General Competition Comment"
            when "wca_id_or_profile" then "WCA ID or WCA Profile Comment"
            when "media" then "Media Comment"
            when "software" then "Software Comment"
            when "different" then "Other Comment"
            else
              raise "Invalid inquiry type: `#{inquiry}`" if inquiry.present?
            end
    Time.now.strftime("[WCA Website] #{topic} by #{name} on %d %b %Y at %R")
  end
end
