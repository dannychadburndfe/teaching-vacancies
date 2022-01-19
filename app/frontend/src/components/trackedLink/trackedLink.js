import { Controller } from '@hotwired/stimulus';
import { eventRequest } from '../../lib/api';

const EVENT_TYPE = 'external_link_click';

// Stimulus controller to send link click data to the app's events endpoint
export default class extends Controller {
  static targets = ['link'];

  // Tracks a user click on the link connected to this controller
  track(e) {
    // Whether or not we should briefly inhibit the default behaviour of the click (i.e. the browser
    // following the link) so we have a chance to send event data.
    // True if and only if the user has used the primary mouse button (or tapped the link on a
    // touchscreen device). Otherwise on e.g. a middle click to open in new tab, or a right click
    // (which for simplicity's sake we also count as a click as the most likely reason is the user
    // is opening in a new tab or copying the URL) we are happy for the default behaviour to go
    // ahead normally (because the page isn't going away and there is ample opportunity for the
    // event to complete).
    const shouldWaitAndRedirect = e.button === 0;

    if (shouldWaitAndRedirect) {
      // Don't let the browser follow the link immediately (before our event request has had a
      // chance to be initiated)
      e.preventDefault();

      // Set a (hopefully) barely noticeable timeout for the redirect to happen anyway regardless
      // of whether or not the event request has completed, so our users don't have to wait around.
      setTimeout(() => { this.#redirect(); }, 100);
    }

    eventRequest(
      EVENT_TYPE,
      this.linkTarget.dataset.sourceData,
      {
        link_type: this.linkTarget.dataset.type,
        location: window.location,
        text: this.linkTarget.innerText,
        href: this.linkTarget.href,
        mouse_button: e.button,
      },
    ).then(() => {
      if (shouldWaitAndRedirect) this.#redirect();
    });
  }

  // Redirect to the target of the link (used if default behaviour has been inhibited)
  #redirect() {
    window.location = this.linkTarget.href;
  }
}
