import { Application } from '@hotwired/stimulus';

import ClipboardController from './components/clipboard/clipboard';
import PanelController from '../../components/panel_component/panel';
import UtilsController from './components/utils';
import AutocompleteController from './components/autocomplete/autocomplete';

const application = Application.start();

application.warnings = true;
application.debug = false;
window.Stimulus = application;

application.register('clipboard', ClipboardController);
application.register('panel', PanelController);
application.register('utils', UtilsController);
application.register('autocomplete', AutocompleteController);
