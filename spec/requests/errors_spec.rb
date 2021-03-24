require "rails_helper"

RSpec.describe "Errors", type: :request do
  describe "GET #not_found" do
    it "returns not found" do
      get not_found_path
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET #unprocessable_entity" do
    it "returns unprocessable_entity" do
      get unprocessable_entity_path
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET #internal_server_error" do
    it "returns internal_server_error" do
      get internal_server_error_path
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  describe "POST #csp_violation" do
    let(:violation) { { "csp-report": { foo: "bar" } }.to_json }
    it "sends the error to Rollbar" do
      expect(Rollbar).to receive(:error).with("CSP Violation", details: violation)

      post errors_csp_violation_path, params: violation
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "GET #invalid_recaptcha" do
    it "sends the error to Rollbar" do
      expect(Rollbar).to receive(:error).with("Invalid recaptcha", details: "this form")

      get invalid_recaptcha_path, params: { form_name: "this form" }
    end

    it "returns unauthorised" do
      get invalid_recaptcha_path
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
