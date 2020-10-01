# Based on a vacancy, concoct a plausible set of search criteria for a job alert subscription
class Search::CriteriaConcocter
  attr_reader :criteria

  def initialize(vacancy)
    @vacancy = vacancy
    @criteria = concoct_search_criteria
  end

private

  def concoct_search_criteria
    {
      location: @vacancy.parent_organisation.postcode,
      radius: (@vacancy.parent_organisation.postcode.present? ? '10' : nil),
      working_patterns: @vacancy.working_patterns,
      phases: @vacancy.education_phases,
      job_roles: @vacancy.job_roles,
      keyword: keyword
    }.delete_if { |_k, v| v.blank? }
  end

  def keyword
    if @vacancy.subjects.present?
      @vacancy.subjects.join(' ')
    elsif @vacancy.job_roles.any?
      # This hash is ordered so that the suggested search query will make more sense in English:
      # preferring 'SEN Leader' over 'Leader SEN', for example, or 'NQT Teacher' over 'Teacher NQT'.
      {
        nqt_suitable: 'NQT',
        sen_specialist: 'SEN',
        leadership: 'Leader',
        teacher: 'Teacher'
      }.map { |k, v| v if @vacancy.job_roles.include? k.to_s }.compact.join(' ')
    else
      get_subjects_from_job_title.presence || get_keywords_from_job_title.presence
    end
  end

  def get_subjects_from_job_title
    subject_options = SUBJECT_OPTIONS.map(&:first)
    single_word_subjects = subject_options.select { |subject| subject.split(' ').one? }
    multi_word_subjects = subject_options.select { |subject| subject.split(' ').many? }
    get_strings_from_job_title(single_word_subjects, multi_word_subjects)
  end

  def get_keywords_from_job_title
    get_strings_from_job_title(%w[Teacher Head Principal SEN], ['Teaching Assistant'])
  end

  def get_strings_from_job_title(words, phrases)
    words_and_phrases = []
    words.each do |word|
      if normalize(@vacancy.job_title).split(' ').include?(normalize(word))
        words_and_phrases << word
      end
    end
    phrases.each do |phrase|
      if normalize(@vacancy.job_title).include?(normalize(phrase))
        words_and_phrases << phrase
      end
    end
    words_and_phrases.join(' ')
  end

  def normalize(string)
    string.downcase.gsub('&', 'and')
  end
end
