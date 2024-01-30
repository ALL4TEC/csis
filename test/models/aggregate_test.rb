# frozen_string_literal: true

require 'test_helper'

class AggregateTest < ActiveSupport::TestCase
  test 'that html tags are removed from created aggregate solution and description' do
    agg = Aggregate.create!({
      title: 'title',
      report_id: Report.first.id,
      rank: 1,
      kind: 'organizational',
      status: 'vulnerability_or_potential_vulnerability',
      severity: 'trivial',
      description: '<P>dezfezf<BR>\nfeizbgfezigb\n<BR>febzigfbezig\n<BR>fezgfzegz<P>',
      solution: '<p>dezfezf<BR>\nfeizbgfezigb\n<BR>febzigfbezig\n<BR>fezgfzegz</p>'
    })
    assert_equal 'dezfezf\nfeizbgfezigb\nfebzigfbezig\nfezgfzegz', agg.description
    assert_equal 'dezfezf\nfeizbgfezigb\nfebzigfbezig\nfezgfzegz', agg.solution
  end

  test 'that html tags are removed from updated aggregate solution and description' do
    agg = Aggregate.create!({
      title: 'title',
      report_id: Report.first.id,
      rank: 1,
      kind: 'organizational',
      status: 'vulnerability_or_potential_vulnerability',
      severity: 'trivial',
      description: 'efzzgrez',
      solution: 'gezgezgzg'
    })
    assert_equal 'efzzgrez', agg.description
    assert_equal 'gezgezgzg', agg.solution
    agg.update!(
      description: '<P>dezfezf<BR>\nfeizbgfezigb\n<BR>febzigfbezig\n<BR>fezgfzegz<P>',
      solution: '<p>dezfezf<BR>\nfeizbgfezigb\n<BR>febzigfbezig\n<BR>fezgfzegz</p>'
    )
    assert_equal 'dezfezf\nfeizbgfezigb\nfebzigfbezig\nfezgfzegz', agg.description
    assert_equal 'dezfezf\nfeizbgfezigb\nfebzigfbezig\nfezgfzegz', agg.solution
  end
end
