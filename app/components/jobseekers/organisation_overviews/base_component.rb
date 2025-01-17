class Jobseekers::OrganisationOverviews::BaseComponent < ViewComponent::Base
  include OrganisationsHelper
  include VacanciesHelper

  delegate :open_in_new_tab_link_to, to: :helpers

  attr_accessor :organisation, :vacancy

  def initialize(vacancy:)
    @vacancy = vacancy
    @organisation = vacancy.parent_organisation
  end
end
