require 'rails_helper'

RSpec.describe VacanciesHelper, type: :helper do
  describe '#new_sections' do
    let(:vacancy) { double('vacancy').as_null_object }

    it 'includes supporting_documents for legacy listings' do
      allow(vacancy).to receive(:supporting_documents).and_return(nil)
      expect(helper.new_sections(vacancy)).to include('supporting_documents')
    end

    it 'includes job_details for legacy listings with missing subjects' do
      allow(helper).to receive(:missing_subjects?).with(vacancy).and_return(true)
      expect(helper.new_sections(vacancy)).to include('job_details')
    end
  end

  describe '#review_heading' do
    let(:vacancy) { double('vacancy').as_null_object }

    it 'returns copy review heading if vacancy state is copy' do
      allow(vacancy).to receive(:published?).and_return(false)
      allow(vacancy).to receive(:state).and_return('copy')

      expect(review_heading(vacancy)).to eql(I18n.t('jobs.copy_review_heading'))
    end

    it 'returns review heading' do
      allow(vacancy).to receive(:published?).and_return(false)
      allow(vacancy).to receive(:state).and_return('not_copy_review')

      expect(review_heading(vacancy)).to eql(I18n.t('jobs.review_heading'))
    end
  end

  describe '#page_title' do
    let(:vacancy) { double('vacancy').as_null_object }
    let(:school) { build(:school) }

    it 'returns copy job title if vacancy state is copy' do
      allow(vacancy).to receive(:published?).and_return(false)
      allow(vacancy).to receive(:state).and_return('copy')
      allow(vacancy).to receive(:job_title).and_return('Test job title')

      expect(page_title(vacancy)).to eql(I18n.t('jobs.copy_job_title', job_title: 'Test job title'))
    end

    it 'returns create a job title if vacancy state is create' do
      allow(vacancy).to receive(:published?).and_return(false)
      allow(vacancy).to receive(:state).and_return('create')
      allow(vacancy).to receive(:job_location).and_return('at_one_school')
      allow(vacancy).to receive(:parent_organisation_name).and_return('Teaching Vacancies Academy')

      expect(page_title(vacancy)).to eql(I18n.t('jobs.create_a_job_title', organisation: 'Teaching Vacancies Academy'))
    end

    it 'returns create a job title if vacancy state is review' do
      allow(vacancy).to receive(:published?).and_return(false)
      allow(vacancy).to receive(:state).and_return('review')
      allow(vacancy).to receive(:job_location).and_return('at_one_school')
      allow(vacancy).to receive(:parent_organisation_name).and_return('Teaching Vacancies Academy')

      expect(page_title(vacancy)).to eql(I18n.t('jobs.create_a_job_title', organisation: 'Teaching Vacancies Academy'))
    end

    it 'returns edit job title' do
      allow(vacancy).to receive(:published?).and_return(true)

      expect(page_title(vacancy)).to eql(I18n.t('jobs.edit_job_title', job_title: vacancy.job_title))
    end
  end

  describe '#hidden_state_field_value' do
    let(:vacancy) { double('vacancy').as_null_object }

    before do
      allow(vacancy).to receive(:published?).and_return(nil)
      allow(vacancy).to receive(:state).and_return(nil)
    end

    it 'returns copy if copy true' do
      expect(hidden_state_field_value(vacancy, true)).to eql('copy')
    end

    it 'returns edit_published if published vacancy' do
      allow(vacancy).to receive(:published?).and_return(true)
      expect(hidden_state_field_value(vacancy)).to eql('edit_published')
    end

    it 'returns current state if vacancy state is copy/review/edit' do
      allow(vacancy).to receive(:published?).and_return(false)

      allow(vacancy).to receive(:state).and_return('copy')
      expect(hidden_state_field_value(vacancy)).to eql('copy')

      allow(vacancy).to receive(:state).and_return('review')
      expect(hidden_state_field_value(vacancy)).to eql('review')

      allow(vacancy).to receive(:state).and_return('edit')
      expect(hidden_state_field_value(vacancy)).to eql('edit')
    end

    it 'returns create' do
      expect(hidden_state_field_value(vacancy)).to eql('create')
    end
  end

  describe '#back_to_manage_jobs_link' do
    let(:vacancy) { double('vacancy').as_null_object }

    before do
      allow(vacancy).to receive(:listed?).and_return(false)
      allow(vacancy).to receive(:published?).and_return(false)
      allow(vacancy).to receive_message_chain(:expiry_time, :future?).and_return(false)
    end

    it 'returns draft jobs link for draft jobs' do
      expect(back_to_manage_jobs_link(vacancy)).to eql(jobs_with_type_organisation_path('draft'))
    end

    it 'returns pending jobs link for scheduled jobs' do
      allow(vacancy).to receive(:published?).and_return(true)
      allow(vacancy).to receive_message_chain(:expiry_time, :future?).and_return(true)
      expect(back_to_manage_jobs_link(vacancy)).to eql(jobs_with_type_organisation_path('pending'))
    end

    it 'returns published jobs link for published jobs' do
      allow(vacancy).to receive(:listed?).and_return(true)
      expect(back_to_manage_jobs_link(vacancy)).to eql(jobs_with_type_organisation_path('published'))
    end

    it 'returns expired jobs link for expired jobs' do
      allow(vacancy).to receive(:published?).and_return(true)
      allow(vacancy).to receive_message_chain(:expiry_time, :past?).and_return(true)
      expect(back_to_manage_jobs_link(vacancy)).to eql(jobs_with_type_organisation_path('expired'))
    end
  end
end
