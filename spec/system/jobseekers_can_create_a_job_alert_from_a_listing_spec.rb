require "rails_helper"

RSpec.describe "Jobseekers can create a job alert from a listing", recaptcha: true do
  let(:school) { create(:school, :primary) }
  let(:vacancy) do
    create(:vacancy,
           job_roles: ["teacher"],
           job_title: "Teacher",
           subjects: ["English"],
           working_patterns: ["full_time"],
           organisation_vacancies_attributes: [{ organisation: school }])
  end

  before do
    allow(Rails.cache)
      .to receive(:fetch)
      .with([:similar_job_ids, vacancy.id], expires_in: Search::SimilarJobs::CACHE_DURATION)
      .and_return([])

    visit job_path(vacancy)
  end

  scenario "can click on the first link to create a job alert using data from the vacancy" do
    click_on I18n.t("jobs.alert.similar.terse")
    expect(page).to have_content(I18n.t("subscriptions.new.title"))
    and_the_search_criteria_are_populated
    click_on I18n.t("buttons.subscribe")
    expect(page).to have_content("There is a problem")

    fill_in_subscription_fields

    message_delivery = instance_double(ActionMailer::MessageDelivery)
    expect(Jobseekers::SubscriptionMailer).to receive(:confirmation) { message_delivery }
    expect(message_delivery).to receive(:deliver_later)
    click_on I18n.t("buttons.subscribe")
  end

  scenario "can click on the second link to create a job alert using data from the vacancy" do
    click_on I18n.t("jobs.alert.similar.verbose.link_text")
    expect(page).to have_content(I18n.t("subscriptions.new.title"))
    and_the_search_criteria_are_populated
  end

  def and_the_search_criteria_are_populated
    expect(page.find_field("jobseekers-subscription-form-keyword-field").value).to eq("English")
    expect(page.find_field("jobseekers-subscription-form-location-field").value).to eq(school.postcode)
    expect(page.find_field("jobseekers-subscription-form-radius-field").value).to eq(Search::CriteriaInventor::DEFAULT_RADIUS_IN_MILES.to_s)
    expect(page.find_field("jobseekers-subscription-form-job-roles-teacher-field")).to be_checked
    expect(page.find_field("jobseekers-subscription-form-job-roles-ect-suitable-field")).not_to be_checked
    expect(page.find_field("jobseekers-subscription-form-phases-primary-field")).to be_checked
    expect(page.find_field("jobseekers-subscription-form-working-patterns-full-time-field")).to be_checked
  end

  def fill_in_subscription_fields
    fill_in "jobseekers_subscription_form[email]", with: "test@example.org"
    choose I18n.t("helpers.label.jobseekers_subscription_form.frequency_options.daily")
  end
end