require 'rails_helper'

RSpec.describe 'Editing a published vacancy' do
  let(:school_group) { create(:school_group) }
  let(:school_1) { create(:school, name: 'First school') }
  let(:school_2) { create(:school, name: 'Second school') }
  let(:session_id) { SecureRandom.uuid }
  let(:vacancy) { create(:vacancy, :at_central_office, :published) }

  before do
    vacancy.organisation_vacancies.create(organisation: school_group)
    allow(SchoolGroupJobsFeature).to receive(:enabled?).and_return(true)
    allow(MultiSchoolJobsFeature).to receive(:enabled?).and_return(true)
    SchoolGroupMembership.find_or_create_by(school_id: school_1.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school_2.id, school_group_id: school_group.id)
    stub_hiring_staff_auth(uid: school_group.uid, session_id: session_id)
  end

  describe '#job_location' do
    scenario 'can edit job location' do
      visit edit_organisation_job_path(vacancy.id)

      expect(page).to have_content(I18n.t('school_groups.job_location_heading.review.central_office'))
      expect(page).to have_content(location(school_group))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eql(
        I18n.t('hiring_staff.organisations.readable_job_location.central_office')
      )

      click_header_link(I18n.t('jobs.job_location'))
      vacancy.job_location = 'at_one_school'
      fill_in_job_location_form_field(vacancy)
      click_on I18n.t('buttons.update_job')

      expect(page.current_path).to eql(organisation_job_schools_path(vacancy.id))
      fill_in_school_form_field(school_1)
      click_on I18n.t('buttons.update_job')

      expect(page.current_path).to eql(edit_organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t('school_groups.job_location_heading.review.at_one_school'))
      expect(page).to have_content(location(school_1))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eql(school_1.name)

      click_header_link(I18n.t('jobs.job_location'))
      vacancy.job_location = 'at_one_school'
      fill_in_job_location_form_field(vacancy)
      click_on I18n.t('buttons.update_job')

      expect(page.current_path).to eql(organisation_job_schools_path(vacancy.id))
      fill_in_school_form_field(school_2)
      click_on I18n.t('buttons.update_job')

      expect(page.current_path).to eql(edit_organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t('school_groups.job_location_heading.review.at_one_school'))
      expect(page).to have_content(location(school_2))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eql(school_2.name)

      click_header_link(I18n.t('jobs.job_location'))
      vacancy.job_location = 'at_multiple_schools'
      fill_in_job_location_form_field(vacancy)
      click_on I18n.t('buttons.update_job')

      expect(page.current_path).to eql(organisation_job_schools_path(vacancy.id))
      check school_1.name, name: 'schools_form[organisation_ids][]', visible: false
      check school_2.name, name: 'schools_form[organisation_ids][]', visible: false
      click_on I18n.t('buttons.update_job')

      expect(page.current_path).to eql(edit_organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t("school_groups.job_location_heading.review.#{vacancy.job_location}"))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eql('More than one school (2)')

      click_header_link(I18n.t('jobs.job_location'))
      vacancy.job_location = 'central_office'
      fill_in_job_location_form_field(vacancy)
      click_on I18n.t('buttons.update_job')

      expect(page.current_path).to eql(edit_organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t('school_groups.job_location_heading.review.central_office'))
      expect(page).to have_content(location(school_group))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eql(
        I18n.t('hiring_staff.organisations.readable_job_location.central_office')
      )
    end
  end
end
