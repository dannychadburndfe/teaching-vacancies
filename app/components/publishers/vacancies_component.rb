class Publishers::VacanciesComponent < ViewComponent::Base
  include DatesHelper

  def initialize(organisation:, sort:, selected_type:, publisher_preference:, sort_form:, email:)
    @organisation = organisation
    @sort = sort
    @publisher_preference = publisher_preference
    @sort_form = sort_form
    @email = email
    @vacancy_types = %w[published expired pending draft awaiting_feedback]
    @selected_type = @vacancy_types.include?(selected_type) ? selected_type : "published"

    set_organisation_options if @organisation.school_group?
    set_vacancies
  end

  def render?
    organisation.all_vacancies.active.any?
  end

  def selected?(vacancy_type)
    selected_type == vacancy_type
  end

  def vacancy_sort_options
    Publishers::VacancySort.new(organisation, selected_type)
  end

  def vacancy_links
    @vacancy_types.map { |vacancy_type| vacancy_type_tab_link(vacancy_type, selected?(vacancy_type)) }
  end

  def grid_column_class
    organisation.school_group? ? "govuk-grid-column-two-thirds" : "govuk-grid-column-full"
  end

  def vacancy_type_tab_link(vacancy_type, selected)
    govuk_link_to t(".#{vacancy_type}.tab_heading"), jobs_with_type_organisation_path(vacancy_type), class: "dashboard-component-navigation__link", "aria-current": ("page" if selected)
  end

  def no_jobs_text
    t("jobs.manage.#{selected_type}.no_jobs.#{publisher_preference.organisations.any? ? 'with' : 'no'}_filters")
  end

  def view_applicants(vacancy)
    return unless vacancy.enable_job_applications?
    return unless include_job_applications?

    applications = vacancy.job_applications.where(status: %w[submitted reviewed shortlisted unsuccessful])

    link = govuk_link_to(tag.span(t("jobs.manage.view_applicants.hidden_text"), class: "govuk-visually-hidden") \
                          + t("jobs.manage.view_applicants", count: applications.count) \
                          + tag.span(" for #{vacancy.job_title}", class: "govuk-visually-hidden"),
                         organisation_job_job_applications_path(vacancy.id),
                         class: "govuk-link--no-visited-state govuk-!-font-size-19")
    tag.div(link)
  end

  def vacancy_expired_over_a_year_ago?(vacancy)
    vacancy.expires_at < 1.year.ago
  end

  private

  attr_reader :publisher_preference, :organisation, :selected_type, :sort, :vacancies

  def set_vacancies
    @vacancies =
      if publisher_preference.organisations.any?
        Vacancy.in_organisation_ids(publisher_preference.organisations.map(&:id))
      elsif organisation.local_authority?
        Vacancy.in_organisation_ids(publisher_preference.schools.map(&:id))
      else
        organisation.all_vacancies
      end

    @vacancies = @vacancies.includes(:job_applications) if include_job_applications?
    @vacancies = @vacancies.send(selected_scope)
                           .order(sort.column => sort.order)
                           .reject { |vacancy| vacancy.job_title.blank? }
                           .map { |v| OrganisationVacancyPresenter.new(v) }
  end

  def include_job_applications?
    organisation.group_type != "local_authority" && @selected_type.in?(%w[published expired])
  end

  def selected_scope
    @selected_type == "published" ? "live" : selected_type
  end

  def set_organisation_options
    schools = organisation.local_authority? ? publisher_preference.schools : organisation.schools
    @organisation_options = schools.not_closed.order(:name).map do |school|
      count = Vacancy.in_organisation_ids(school.id).send(selected_scope).count
      OpenStruct.new({ id: school.id, name: school.name, label: "#{school.name} (#{count})" })
    end

    return if organisation.local_authority?

    count = Vacancy.in_organisation_ids(organisation.id).send(selected_scope).count
    @organisation_options.unshift(
      OpenStruct.new({ id: organisation.id, name: "Trust head office", label: "Trust head office (#{count})" }),
    )
  end
end
