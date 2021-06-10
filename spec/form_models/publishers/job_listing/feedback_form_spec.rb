require "rails_helper"

RSpec.describe Publishers::JobListing::FeedbackForm, type: :model do
  subject { described_class.new(params) }
  let(:params) do
    {
      email: "email@example.com",
      rating: "neither",
      report_a_problem: "no",
      user_participation_response: "interested",
    }
  end

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to allow_value("email@example").for(:email) }
  it { is_expected.to_not allow_value("invalid@email@com").for(:email) }
  it { is_expected.to validate_inclusion_of(:rating).in_array(Feedback.ratings.keys) }
  it { is_expected.to validate_inclusion_of(:report_a_problem).in_array(%w[yes no]) }
  it {
    is_expected.to validate_inclusion_of(:user_participation_response)
                    .in_array(Feedback.user_participation_responses.keys)
  }
end
