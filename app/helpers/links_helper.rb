module LinksHelper
  def tracked_link_to(text, href, event_data = {}, **kwargs)
    govuk_link_to(text, href, **kwargs.deep_merge(data: {
      controller: "tracked-link",
      action: %w[click auxclick contextmenu].map { |a| "#{a}->tracked-link#track" }.join(" "),
      "tracked-link-target": "link",
      "event-data": FrontendTrackingData.sign(event_data.merge(text: text, href: href)),
    }))
  end

  def open_in_new_tab_link_to(text, href, **kwargs)
    govuk_link_to("#{text} (opens in new tab)", href, target: "_blank", rel: "noreferrer noopener", **kwargs)
  end

  def open_in_new_tab_button_link_to(text, href, **kwargs)
    govuk_button_link_to("#{text} (opens in new tab)", href, target: "_blank", rel: "noopener", **kwargs)
  end
end
