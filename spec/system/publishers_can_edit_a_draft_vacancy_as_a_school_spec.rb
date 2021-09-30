require "rails_helper"

RSpec.describe "Publishers can edit a draft vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }

  before { login_publisher(publisher: publisher, organisation: school) }

  context "editing an incomplete draft vacancy" do
    context "when there are steps with errors" do
      let(:vacancy_with_errors) do
        create(:vacancy, :draft, job_roles: %w[teacher], salary: nil)
      end

      before do
        vacancy_with_errors.organisation_vacancies.create(organisation: school)
        visit organisation_job_path(vacancy_with_errors.id)
      end

      scenario "cannot submit a incomplete draft from the manage job listing page" do
        expect(page).to have_content(I18n.t("pay_package_errors.salary.blank"))
        expect(page).to_not have_content(I18n.t("buttons.submit_job_listing"))
      end

      scenario "correct status tag is displayed" do
        within(".review-component#pay_package") do
          expect(page).to have_content(I18n.t("shared.status_tags.action_required"))
        end
      end
    end

    context "when no questions have been answered in a step" do
      let(:incomplete_vacancy) { create(:vacancy, :draft, job_roles: %w[teacher], salary: nil, completed_steps: completed_steps) }
      let(:completed_steps) do
        %w[job_role job_details pay_package important_dates documents applying_for_the_job job_summary]
      end

      before do
        incomplete_vacancy.organisation_vacancies.create(organisation: school)
        visit organisation_job_path(incomplete_vacancy.id)
      end

      scenario "cannot submit a incomplete draft from the manage job listing page" do
        expect(page).to have_content(I18n.t("pay_package_errors.salary.blank"))
        expect(page).to_not have_content(I18n.t("buttons.submit_job_listing"))
      end

      scenario "correct status tag is displayed" do
        within(".review-component#working_patterns") do
          expect(page).to have_content(I18n.t("shared.status_tags.not_started"))
        end
      end
    end
  end

  context "editing a complete draft vacancy" do
    let(:complete_vacancy) { create(:vacancy, :draft, job_roles: %w[teacher]) }

    before { complete_vacancy.organisation_vacancies.create(organisation: school) }

    describe "cancel_and_return_later" do
      xscenario "can cancel and return from job details page" do
        visit organisation_job_path(complete_vacancy.id)

        click_header_link(I18n.t("publishers.vacancies.steps.job_details"))
        expect(page).to have_content(I18n.t("buttons.cancel_and_return"))

        click_on I18n.t("buttons.cancel_and_return")
        expect(page.current_path).to eq(organisation_job_path(complete_vacancy.id))
      end
    end

    describe "submitting a completed draft" do
      let(:completed_steps) do
        %w[job_role job_details pay_package working_patterns important_dates documents applying_for_the_job job_summary]
      end

      before { visit organisation_job_path(complete_vacancy.id) }

      scenario "can submit a completed draft from the manage job listing page" do
        click_on I18n.t("buttons.submit_job_listing")

        expect(page.current_path).to eq(organisation_job_summary_path(complete_vacancy.id))
      end

      scenario "correct status tag is displayed" do
        completed_steps.each do |step|
          within(".review-component##{step}") do
            expect(page).to have_content(I18n.t("shared.status_tags.complete"))
          end
        end
      end
    end
  end
end
