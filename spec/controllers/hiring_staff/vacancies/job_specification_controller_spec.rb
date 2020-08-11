require 'rails_helper'

RSpec.describe HiringStaff::Vacancies::JobSpecificationController, type: :controller do
  let(:session) { double('session') }
  let(:vacancy) { double('vacancy') }
  let(:vacancy_id) { double('test_vacancy_id') }
  let(:school_id) { double('test_school_id') }
  let(:job_specification_form) { class_double(JobSpecificationForm) }

  before do
    allow(job_specification_form).to receive(:new)

    allow(controller).to receive(:session).and_return(session)
    allow(session).to receive(:[]).with(:urn).and_return('urn')
    allow(session).to receive(:[]).with(:vacancy_attributes).and_return(nil)
    allow(session).to receive(:id).and_return(nil)
    allow(controller).to receive_message_chain(:current_user, :accepted_terms_and_conditions?).and_return(true)
    allow(controller).to receive_message_chain(:current_user, :last_activity_at).and_return(Time.zone.now)
    allow(controller).to receive_message_chain(:current_user, :update)

    allow(vacancy).to receive(:id).and_return(vacancy_id)
    allow(vacancy).to receive(:persisted?).and_return(true)
    allow(vacancy).to receive(:state).and_return('create')
    controller.instance_variable_set(:@vacancy, vacancy)
  end

  describe '#set_up_url' do
    before do
      allow(vacancy).to receive(:attributes).and_return(double('attributes').as_null_object)
    end

    context 'vacancy is present' do
      it 'uses the update action' do
        get :show
        expect(controller.instance_variable_get(:@form_submission_url_method)).to eql('patch')
        expect(controller.instance_variable_get(:@form_submission_url))
          .to eql(organisation_job_job_specification_path(vacancy_id))
      end
    end

    context 'vacancy id is not present' do
      before do
        allow(controller).to receive_message_chain(:current_school, :id).and_return(school_id)
        controller.instance_variable_set(:@vacancy, nil)
      end

      it 'uses the create action' do
        get :show
        expect(controller.instance_variable_get(:@form_submission_url_method)).to eql('post')
        expect(controller.instance_variable_get(:@form_submission_url))
          .to eql(job_specification_organisation_job_path)
      end
    end
  end

  describe '#append_suitable_for_nqts_to_job_roles' do
    let(:params) do
      { job_specification_form: { suitable_for_nqt: suitable_for_nqt, job_roles: [] } }
    end

    before do
      allow(controller).to receive(:params).and_return(params)
    end

    context 'when suitable for nqts is yes' do
      let(:suitable_for_nqt) { 'yes' }

      it 'appends Suitable for NQTs to job roles' do
        subject.send(:append_suitable_for_nqts_to_job_roles)
        expect(controller.params[:job_specification_form][:job_roles]).to eql([:nqt_suitable])
      end
    end

    context 'when suitable for nqts is no' do
      let(:suitable_for_nqt) { 'no' }

      it 'does not append Suitable for NQTs to job roles' do
        subject.send(:append_suitable_for_nqts_to_job_roles)
        expect(controller.params[:job_specification_form][:job_roles]).to be_blank
      end
    end
  end
end
