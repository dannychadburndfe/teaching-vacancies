require "rails_helper"

RSpec.describe "Jobseekers can add qualifications to their job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
  end

  context "adding a qualification" do
    before do
      visit jobseekers_job_application_build_path(job_application, :qualifications)
      click_on I18n.t("buttons.add_qualification")
    end

    it "allows jobseekers to add a graduate degree" do
      validates_step_complete(button: I18n.t("buttons.continue"))
      select_qualification_category("Undergraduate degree")
      expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.undergraduate"))
      validates_step_complete(button: I18n.t("buttons.save_qualification.one"))
      fill_in_undergraduate_degree
      click_on I18n.t("buttons.save_qualification.one")
      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :qualifications))
      expect(page).to have_content(I18n.t("buttons.add_another_qualification"))
      expect(page).to have_content("Undergraduate degree")
      expect(page).to have_content("University of Life")
      expect(page).not_to have_content("Subjects and grades")
      expect(page).not_to have_content("School, college, or other organisation")
    end

    it "allows jobseekers to add a custom qualification or course (category 'other')" do
      select_qualification_category("Other qualification or course")
      expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.other"))
      validates_step_complete(button: I18n.t("buttons.save_qualification.one"))
      fill_in_other_qualification
      click_on I18n.t("buttons.save_qualification.one")
      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :qualifications))
      expect(page).to have_content("Superteacher Certificate")
      expect(page).to have_content("Teachers Academy")
      expect(page).to have_content("I expect to finish next year")
      expect(page).not_to have_content("Grade")
      expect(page).not_to have_content("Year")
    end

    it "allows jobseekers to add a common secondary qualification" do
      select_qualification_category("GCSE")
      expect(page).to have_link(I18n.t("buttons.cancel"), href: select_category_jobseekers_job_application_qualifications_path(job_application))
      expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.gcse"))
      validates_step_complete(button: I18n.t("buttons.save_qualification.other"))
      fill_in_gcse
      # TODO: fill_in_another_gcse
      click_on I18n.t("buttons.save_qualification.other")
      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :qualifications))
      expect(page).to have_content("GCSEs")
      expect(page).to have_content("Churchill School for Gifted Macaques")
      expect(page).to have_content("Maths – 110%")
      expect(page).to have_content("PE – 90%")
      expect(page).to have_content("2020")
    end

    it "allows jobseekers to add a custom secondary qualification" do
      select_qualification_category("Other secondary qualification")
      expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.other_secondary"))
      validates_step_complete(button: I18n.t("buttons.save_qualification.other"))
      fill_in_secondary_qualification
      # TODO: fill_in_another_secondary_qualification
      click_on I18n.t("buttons.save_qualification.other")
      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :qualifications))
      expect(page).to have_content("Welsh Baccalaureate")
      expect(page).to have_content("Happy Rainbows School for High Achievers")
      expect(page).to have_content("Science – 5")
      expect(page).to have_content("German – 4")
      expect(page).to have_content("2020")
    end
  end

  context "when there is exactly one qualification" do
    let!(:qualification) do
      create(:qualification,
             category: "other_secondary",
             institution: "John Mason School",
             job_application: job_application)
    end

    it "allows jobseekers to edit a single qualification" do
      visit jobseekers_job_application_build_path(job_application, :qualifications)

      click_on I18n.t("buttons.edit")
      expect(page).to have_link(I18n.t("buttons.cancel"), href: jobseekers_job_application_build_path(job_application, :qualifications))

      fill_in "School", with: "St Nicholas School"
      click_on I18n.t("buttons.save_qualification.one")

      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :qualifications))
      expect(page).not_to have_content("John")
      expect(page).to have_content("Nicholas")
    end
  end
end
