# frozen_string_literal: true

require 'test_helper'
require 'utils/tmp_file_helper'

class AggregatesHelperTest < ActionView::TestCase
  def setup
    # rubocop:disable Rails/I18nLocaleAssignment
    I18n.locale = :fr
    # rubocop:enable Rails/I18nLocaleAssignment
  end

  test 'translate function of aggregate severity' do
    agg = Aggregate.new
    agg.severity = Aggregate.severities[:critical]
    assert_equal(
      I18n.t('pdf.score_tab.immediate_correction'),
      AggregatesHelper.translate_severity(agg.severity),
      'Translator does not work!'
    )
  end

  test 'color fill function of aggregate severity' do
    agg = Aggregate.new
    agg.severity = Aggregate.severities[:critical]
    assert_equal(
      'DB2619',
      AggregatesHelper.color_fill_severity(agg.severity),
      'Color fill mapping does not work!'
    )
  end

  test 'text color function of aggregate severity' do
    agg = Aggregate.new
    agg.severity = Aggregate.severities[:critical]
    assert_equal(
      WHITE,
      AggregatesHelper.color_text_severity(agg.severity),
      'Text color mapping does not work!'
    )
  end

  test 'translate status function of status' do
    agg = Aggregate.new
    agg.status = Aggregate.statuses[:information_gathered]
    assert_equal(
      I18n.t('labels.gathered_information'),
      AggregatesHelper.translate_status(agg.status),
      'Translate status does not work!'
    )
  end
end
