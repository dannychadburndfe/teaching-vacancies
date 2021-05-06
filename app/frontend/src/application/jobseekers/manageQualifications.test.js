import manageQualifications, {
  addAddSubjectEventListener,
  addSubjectHandler,
  deleteRowHandler,
  renumberRow,
  renumberRows,
  DELETE_BUTTON_CLASSNAME,
  FIELDSET_CLASSNAME,
  GOVUK_INPUT_CLASSNAME,
  ROW_CLASS,
  SUBJECT_LINK_ID,
} from './manageQualifications';

describe('manageQualifications', () => {
  const originalMarkup = `<div class="${FIELDSET_CLASSNAME}">
      <div class="${ROW_CLASS}">
        <label for="subject1">Subject 1</label>
        <input class="${GOVUK_INPUT_CLASSNAME}" id="s1" value="Maths" />
        <a class="${DELETE_BUTTON_CLASSNAME}" href="#">delete subject</a>
      </div>
      <div class="${ROW_CLASS}">
        <label for="subject2">Subject 2</label>
        <input class="${GOVUK_INPUT_CLASSNAME}" id="s2" value="Music" />
        <a class="${DELETE_BUTTON_CLASSNAME}" href="#">delete subject</a>
      </div>
      <div class="${ROW_CLASS} js-hidden">
        <label for="subject3">Subject 3</label>
        <input class="${GOVUK_INPUT_CLASSNAME}" class="govuk-input--error" id="s3" value="Geography" />
        <a class="${DELETE_BUTTON_CLASSNAME}" href="#">delete subject</a>
      </div>
      <div class="${ROW_CLASS} js-hidden">
        <label for="subject4">Subject 4</label>
        <input class="${GOVUK_INPUT_CLASSNAME}" id="s4" value="Economics 101" />
        <a class="${DELETE_BUTTON_CLASSNAME}" href="#">delete subject</a>
      </div>
    </div>
    <a id="${SUBJECT_LINK_ID}" href="#">Add subject</a>`;

  beforeEach(() => {
    document.body.innerHTML = originalMarkup;
  });

  describe('Add subject event listener', () => {
    document.body.innerHTML = originalMarkup;
    const button = document.getElementById(SUBJECT_LINK_ID);
    test('when the link is clicked, it adds a subject', () => {
      manageQualifications.addSubject = jest.fn();
      const addSubjectSpy = jest.spyOn(manageQualifications, 'addSubjectHandler');
      addAddSubjectEventListener(button);
      button.dispatchEvent(new Event('click'));
      expect(addSubjectSpy).toHaveBeenCalled();
    });
  });

  describe('add subject event handler', () => {
    manageQualifications.renumberRow = jest.fn();

    const initialNumberOfRows = document.getElementsByClassName(ROW_CLASS).length;

    beforeEach(() => {
      addSubjectHandler();
    });

    test('adds a row', () => {
      expect(document.getElementsByClassName(ROW_CLASS).length).toBe(initialNumberOfRows + 1);
    });

    test('renumbers row, discarding values and errors', () => {
      const renumberRowsSpy = jest.spyOn(manageQualifications, 'renumberRows');
      expect(renumberRowsSpy).toHaveBeenCalled();
    });

    test('puts the new subject input in focus', () => {
      expect(document.getElementsByClassName(ROW_CLASS)[2].querySelector('input') === document.activeElement).toBe(true);
    });
  });

  describe('delete row event handler', () => {
    manageQualifications.renumberRows = jest.fn();
    const renumberRowsSpy = jest.spyOn(manageQualifications, 'renumberRows');
    const rowNumberToDelete = '2';

    beforeEach(() => {
      deleteRowHandler(document.getElementsByClassName(ROW_CLASS)[rowNumberToDelete].children[2]);
    });

    test('renumbers the rows', () => {
      expect(renumberRowsSpy).toHaveBeenCalledTimes(5);
    });
  });

  describe('renumber rows', () => {
    manageQualifications.renumberRow = jest.fn();
    const renumberRowSpy = jest.spyOn(manageQualifications, 'renumberRow');

    beforeEach(() => {
      renumberRows();
    });

    test('renumbers 4 subject rows', () => {
      expect(renumberRowSpy).toHaveBeenCalledTimes(4);
    });
  });

  describe('renumber row', () => {
    manageQualifications.renumberCell = jest.fn();
    const renumberCellSpy = jest.spyOn(manageQualifications, 'renumberCell');

    const row = document.getElementsByClassName(FIELDSET_CLASSNAME)[0];

    beforeEach(() => {
      renumberRow(row, 3, false);
    });

    test('renumbers all cells', () => {
      expect(renumberCellSpy).toHaveBeenCalledTimes(12);
    });
  });

  describe('renumbers cells', () => {
    test('renumbers all cell attributes and labels', () => {
      renumberRows();
      expect(document.getElementsByClassName(ROW_CLASS)[3].children[0].innerHTML).toBe('Subject 4');
      expect(document.getElementsByClassName(ROW_CLASS)[3].children[0].getAttribute('for')).toBe('subject4');
      expect(document.getElementsByClassName(ROW_CLASS)[3].children[1].value).toBe('Economics 101');
    });
  });
});
