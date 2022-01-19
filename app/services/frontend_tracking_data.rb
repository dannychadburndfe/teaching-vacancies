# Provides helper methods to create tamper-proof marshalled representations of tracking data for
# use by frontend tracking (so malicious users cannot send arbitrary events to the endpoint).
class FrontendTrackingData
  def self.sign(data)
    verifier.generate(data, purpose: :tracking)
  end

  def self.verify(data)
    verifier.verify(data, purpose: :tracking)
  end

  private_class_method def self.verifier
    Rails.application.message_verifier("tracking")
  end
end
