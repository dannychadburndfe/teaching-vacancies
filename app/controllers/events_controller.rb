class EventsController < ApplicationController
  EXTERNAL_EVENT_ALLOWLIST = %w[external_link_click].freeze

  skip_after_action :trigger_page_visited_event

  def create
    type = event_params[:type]
    raise "Invalid external event: '#{type}'" unless type.in?(EXTERNAL_EVENT_ALLOWLIST)

    data = event_params[:data]
    request_event.trigger(type, data)

    head :no_content
  end

  private

  def event_params
    params.require(:event).permit(:type, data: {})
  end
end
