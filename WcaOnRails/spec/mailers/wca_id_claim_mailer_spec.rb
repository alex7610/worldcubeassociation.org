# frozen_string_literal: true
require "rails_helper"

RSpec.describe WcaIdClaimMailer, type: :mailer do
  describe "notify_board_of_confirmed_competition" do
    let(:delegate) { FactoryGirl.create :delegate }
    let(:person) { FactoryGirl.create :person }
    let(:user_claiming_wca_id) { FactoryGirl.create :user, unconfirmed_wca_id: person.wca_id, delegate_to_handle_wca_id_claim: delegate, dob_verification: person.dob }
    let(:mail) { WcaIdClaimMailer.notify_delegate_of_wca_id_claim(user_claiming_wca_id) }

    it "renders" do
      expect(mail.to).to eq([delegate.email])
      expect(mail.cc).to eq([user_claiming_wca_id.email])
      expect(mail.from).to eq(["notifications@worldcubeassociation.org"])
      expect(mail.reply_to).to eq([user_claiming_wca_id.email])

      expect(mail.subject).to eq("#{user_claiming_wca_id.email} just requested WCA ID #{person.wca_id}")
      expect(mail.body.encoded).to match(edit_user_path(user_claiming_wca_id.id, anchor: "wca_id"))
    end
  end

  describe "notify_user_of_delegate_demotion" do
    let(:demoted_delegate) { FactoryGirl.create :user }
    let(:user_claiming_wca_id) { FactoryGirl.create :user }
    let(:mail) { WcaIdClaimMailer.notify_user_of_delegate_demotion(user_claiming_wca_id, demoted_delegate) }

    it "sets appropriate headers" do
      expect(mail.to).to eq [user_claiming_wca_id.email]
      expect(mail.from).to eq ["notifications@worldcubeassociation.org"]
      expect(mail.reply_to).to eq ["notifications@worldcubeassociation.org"]
    end

    it "renders body" do
      expect(mail.subject).to eq "Repeat your WCA ID claim"
      body = mail.body.encoded
      expect(body).to match user_claiming_wca_id.name
      expect(body).to match demoted_delegate.name
      expect(body).to match profile_claim_wca_id_url
    end
  end
end
