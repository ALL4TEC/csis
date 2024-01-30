# frozen_string_literal: true

require 'test_helper'

class AggregatesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot create vulnerability_scan aggregate' do
    post report_aggregates_path(PentestReport.first), params: {
      aggregate: {
        title: 'new',
        kind: 'vulnerability_scan'
      }
    }
    check_not_authenticated
  end

  test 'authenticated staff can create vulnerability_scan aggregate' do
    report = PentestReport.first
    sign_in users(:staffuser)
    post report_aggregates_path(report), params: {
      aggregate: {
        title: 'new',
        kind: 'vulnerability_scan'
      }
    }
    assert_redirected_to report_aggregates_path(report)
  end

  test 'unauthenticated cannot create appendix aggregate' do
    post report_aggregates_path(PentestReport.first), params: {
      aggregate: {
        title: 'new',
        kind: 'appendix'
      }
    }
    check_not_authenticated
  end

  test 'authenticated staff can create appendix aggregate' do
    report = PentestReport.first
    sign_in users(:staffuser)
    post report_aggregates_path(report), params: {
      aggregate: {
        title: 'new',
        kind: 'appendix'
      }
    }
    assert_redirected_to report_aggregates_path(report)
  end

  test 'unauthenticated cannot view edit action aggregate attachment page' do
    get edit_attachment_aggregate_path(Aggregate.first)
    check_not_authenticated
  end

  test 'authenticated staff can view edit action aggregate attachment page' do
    sign_in users(:staffuser)
    get edit_attachment_aggregate_path(Aggregate.first)
    assert_response :success
  end

  test 'unauthenticated cannot update action aggregate attachment' do
    put update_attachment_aggregate_path(Aggregate.first), params: {
      aggregate: {
        action_ids: Action.ids
      }
    }
    check_not_authenticated
  end

  test 'authenticated staff can update action aggregate attachment' do
    aggregate = Aggregate.first
    sign_in users(:staffuser)
    put update_attachment_aggregate_path(aggregate), params: {
      aggregate: {
        action_ids: Action.ids
      }
    }
    assert_equal I18n.t('aggregates.notices.attachment_success'), flash[:notice]
  end

  test 'unauthenticated cannot reorder aggregates' do
    report = pentest_reports(:hospiville)
    aggregate_data = []

    report.aggregates.applicative_kind.order(rank: :desc).each_with_index do |agg, index|
      aggregate_data << { id: agg.id, position: index + 1 }
    end

    post aggregates_reorder_report_path(report.id), params: {
      kind: 'applicative',
      aggregates_data: aggregate_data.to_json
    }
    check_unauthorized
  end

  test 'authenticated staff can reorder aggregates' do
    report = pentest_reports(:hospiville)
    sign_in users(:staffuser)
    aggregate_data = []

    report.aggregates.applicative_kind.order(rank: :desc).each_with_index do |agg, index|
      aggregate_data << { id: agg.id, position: index + 1 }
    end

    post aggregates_reorder_report_path(report.id), params: {
      kind: 'applicative',
      aggregates_data: aggregate_data.to_json
    }
    assert_equal aggregate_data.pluck(:id).to_json, @response.body
  end

  test 'unauthenticated cannot merge aggregates' do
    report = scan_reports(:mapui)
    aggregate = report.aggregates.find_by(title: 'First aggregate')
    aggregate2 = report.aggregates.find_by(title: 'Bis aggregate')

    put merge_aggregate_path(aggregate.id), params: {
      aggregate_ids: aggregate2.id
    }
    check_unauthorized
  end

  test 'authenticated staff can merge one aggregate into another aggregate' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    aggregate = report.aggregates.find_by(title: 'First aggregate')
    aggregate2 = report.aggregates.find_by(title: 'Bis aggregate')
    aggregate2.update(scope: '1')

    prev_occ = aggregate.vm_occurrences.ids + aggregate.wa_occurrences.ids +
               aggregate2.vm_occurrences.ids + aggregate2.wa_occurrences.ids

    put merge_aggregate_path(aggregate.id), params: {
      aggregate_ids: aggregate2.id
    }

    assert_raises ActiveRecord::RecordNotFound do
      Aggregate.find(aggregate2.id)
    end
    aggregate.reload
    new_occ = aggregate.vm_occurrences.ids + aggregate.wa_occurrences.ids
    assert_equal new_occ.sort, prev_occ.sort
  end

  test 'authenticated staff can merge multiple aggregates into another aggregate' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    aggregate = report.aggregates.find_by(title: 'First aggregate')
    aggregate.update(scope: '1')
    aggregates = report.aggregates.where.not(title: 'First aggregate')

    prev_occ = aggregate.vm_occurrences.ids + aggregate.wa_occurrences.ids
    aggregates.each do |agg|
      prev_occ += agg.vm_occurrences.ids + agg.wa_occurrences.ids
    end

    put merge_aggregate_path(aggregate.id), params: {
      aggregate_ids: aggregates.ids.join(',')
    }

    aggregates.each do |agg|
      assert_raises ActiveRecord::RecordNotFound do
        Aggregate.find(agg.id)
      end
    end
    aggregate.reload
    new_occ = aggregate.vm_occurrences.ids + aggregate.wa_occurrences.ids
    assert_equal new_occ.sort, prev_occ.sort
  end

  # test 'authenticated staff cannot merge an aggregate containing same occurrences as another
  #       aggregate into this aggregate' do
  #   sign_in users(:staffuser)
  #   report = scan_reports(:mapui)
  #   aggregate = report.aggregates.find_by(title: 'First aggregate')
  #   aggregate2 = report.aggregates.find_by(title: 'Bis aggregate')
  #   aggregate2.update(scope: '1')

  #   common_vm_occ = VmOccurrence.create!(scan: VmScan.first, vulnerability: Vulnerability.first)
  #   common_wa_occ = WaOccurrence.create!(scan: WaScan.first, vulnerability: Vulnerability.first)
  #   aggregate.vm_occurrences << common_vm_occ
  #   aggregate2.vm_occurrences << common_vm_occ
  #   aggregate.wa_occurrences << common_wa_occ
  #   aggregate2.wa_occurrences << common_wa_occ

  #   prev_occ = aggregate.vm_occurrences.ids + aggregate.wa_occurrences.ids +
  #              aggregate2.vm_occurrences.ids + aggregate2.wa_occurrences.ids

  #   put merge_aggregate_path(aggregate.id), params: {
  #     aggregate_ids: aggregate2.id
  #   }

  #   assert_raises ActiveRecord::RecordNotFound do
  #     Aggregate.find(aggregate2.id)
  #   end
  #   aggregate.reload
  #   new_occ = aggregate.vm_occurrences.ids + aggregate.wa_occurrences.ids
  #   assert_equal new_occ.sort, prev_occ.sort
  # end

  test 'authenticated staff merging an aggregate into himself does not break anything' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    aggregate = report.aggregates.find_by(title: 'First aggregate')
    prev_occ = aggregate.vm_occurrences.ids + aggregate.wa_occurrences.ids

    put merge_aggregate_path(aggregate.id), params: {
      aggregate_ids: aggregate.id
    }

    assert Aggregate.find(aggregate.id).present?
    aggregate.reload
    new_occ = aggregate.vm_occurrences.ids + aggregate.wa_occurrences.ids
    assert_equal new_occ.sort, prev_occ.sort
  end

  test 'authenticated staff merging two aggregates from != reports does not break anything' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    aggregate = report.aggregates.find_by(title: 'First aggregate')
    aggregate2 = scan_reports(:mapui2).aggregates.first
    prev_occ = aggregate.vm_occurrences.ids + aggregate.wa_occurrences.ids

    put merge_aggregate_path(aggregate.id), params: {
      aggregate_ids: aggregate2.id
    }

    assert Aggregate.find(aggregate.id).present?
    assert Aggregate.find(aggregate2.id).present?
    aggregate.reload
    new_occ = aggregate.vm_occurrences.ids + aggregate.wa_occurrences.ids
    assert_equal new_occ.sort, prev_occ.sort
  end

  test 'authenticated staff merging aggregates result in all scopes merged & uniq' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    aggregate = report.aggregates.find_by(title: 'First aggregate')
    aggregate.update(scope: "1\r\n2")
    aggregates = report.aggregates.where.not(title: 'First aggregate')
    aggregates.each do |agg|
      agg.update(scope: "2\r\n3")
    end

    put merge_aggregate_path(aggregate.id), params: {
      aggregate_ids: aggregates.ids.join(',')
    }

    aggregate.reload
    assert_equal "1\r\n2\r\n3", aggregate.scope
  end

  test 'unauthenticated cannot move occurrences' do
    report = scan_reports(:mapui)
    aggregate = report.aggregates.find_by(title: 'First aggregate')
    aggregate2 = report.aggregates.find_by(title: 'Bis aggregate')
    occurrence = aggregate2.vm_occurrences.first
    occurrences_data = map_occurrences_data([occurrence], aggregate2)

    put merge_aggregate_path(aggregate.id), params: {
      occurrences_data: occurrences_data
    }
    check_unauthorized
  end

  test 'authenticated staff can move occurrences through aggregates of same kind from same
        report' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    aggregate = report.aggregates.find_by(title: 'First aggregate')
    aggregate2 = report.aggregates.find_by(title: 'Bis aggregate')
    occurrence = aggregate2.vm_occurrences.first
    occurrences_data = map_occurrences_data([occurrence], aggregate2)

    prev_occ = aggregate.vm_occurrences.ids + [occurrence.id]
    put merge_aggregate_path(aggregate.id), params: {
      occurrences_data: occurrences_data
    }

    aggregate2.reload
    assert_raises ActiveRecord::RecordNotFound do
      aggregate2.vm_occurrences.find(occurrence.id)
    end
    aggregate.reload
    new_occ = aggregate.vm_occurrences.ids
    assert_equal new_occ.sort, prev_occ.sort
  end

  test 'authenticated staff can move multiple occurrences through aggregates' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    aggregate = report.aggregates.find_by(title: 'First aggregate')
    aggregate2 = report.aggregates.find_by(title: 'Bis aggregate')
    occurrences = aggregate2.vm_occurrences
    occurrences_data = map_occurrences_data(occurrences, aggregate2)

    prev_occ = aggregate.vm_occurrences.ids + aggregate.wa_occurrences.ids +
               occurrences.ids

    put merge_aggregate_path(aggregate.id), params: {
      occurrences_data: occurrences_data
    }

    aggregate2.reload
    occurrences.each do |occ|
      assert_raises ActiveRecord::RecordNotFound do
        aggregate2.vm_occurrences.find(occ.id)
      end
    end
    aggregate.reload
    new_occ = aggregate.vm_occurrences.ids + aggregate.wa_occurrences.ids
    assert_equal new_occ.sort, prev_occ.sort
  end

  test 'authenticated staff moving occ from an aggregate into himself does not break anything' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    aggregate = report.aggregates.find_by(title: 'First aggregate')
    occurrence = aggregate.vm_occurrences.first
    occurrences_data = map_occurrences_data([occurrence], aggregate)

    put merge_aggregate_path(aggregate.id), params: {
      occurrences_data: occurrences_data
    }

    assert aggregate.vm_occurrences.find(occurrence.id).present?
    assert_equal 1, aggregate.vm_occurrences.where(id: occurrence.id).count
  end

  test 'authenticated staff moving occ between aggregates with != reports does nothing' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    aggregate = report.aggregates.find_by(title: 'First aggregate')
    aggregate2 = scan_reports(:mapui2).aggregates.last
    occurrence = aggregate2.wa_occurrences.first
    occurrences_data = map_occurrences_data([occurrence], aggregate2)

    assert_raises ActiveRecord::RecordNotFound do
      aggregate.wa_occurrences.find(occurrence.id)
    end

    put merge_aggregate_path(aggregate.id), params: {
      occurrences_data: occurrences_data
    }

    assert_raises ActiveRecord::RecordNotFound do
      aggregate.wa_occurrences.find(occurrence.id)
    end
    assert aggregate2.wa_occurrences.find(occurrence.id).present?
  end

  test 'unauthenticated cannot duplicate aggregates' do
    aggregate_ids = ''
    report_ids = ''
    post aggregates_duplicate_path, params: {
      report_ids: report_ids,
      aggregate_ids: aggregate_ids
    }
    check_unauthorized
  end

  test 'authenticated staff can duplicate aggregates in report' do
    sign_in users(:staffuser)
    # GIVEN
    # A report with some unaggregated occurrences
    report = scan_reports(:mapui)
    # Report has 3 unaggregated wa occurrences:
    assert_equal 3, report.unaggregated_was.count
    unagg_ids = report.unaggregated_was.pluck(:id)
    assert_equal 1, report.wa_aggregates.count
    # Three aggregates linked to another report with occurrences in report.unaggregated
    # aggregates(:eight) is linked to 2 occurrences of report.unaggregated_was
    first_agg = aggregates(:aggregate_eight)
    first_agg_wa_occ_ids = first_agg.wa_occurrences.pluck(:id)
    assert(first_agg_wa_occ_ids.all? { |occ_id| unagg_ids.include?(occ_id) })
    remaining_unagg_id = (unagg_ids - first_agg_wa_occ_ids).first
    # We create a new aggregate linked to mapui2 and remaining report.unaggregated_was
    # to check rank is well computed
    agg_hash = {
      title: 'FHeozfhfozhf',
      description: 'Fezfjzohgjfzoehg',
      solution: 'Veritatis sunt est. Culpa voluptas nemo. Saepe aut eos.',
      status: 'information_gathered',
      severity: 'medium',
      report_id: scan_reports(:mapui2).id,
      kind: 'applicative',
      rank: 99,
      visibility: 'shown'
    }
    bis_agg = Aggregate.create!(agg_hash)
    bis_agg.wa_occurrences = report.unaggregated_was.select { |occ| occ.id == remaining_unagg_id }
    # New one without occurrence
    new_agg_hash = {
      title: 'Server accepts unnecessarily large POST request body',
      description: 'Quam autem esse. In voluptatibus dolores. Voluptatem quod unde.',
      solution: 'Veritatis sunt est. Culpa voluptas nemo. Saepe aut eos.',
      status: 'information_gathered',
      severity: 'medium',
      report_id: scan_reports(:mapui2).id,
      kind: 'applicative',
      rank: 100,
      visibility: 'shown'
    }
    new_agg = Aggregate.create!(new_agg_hash)
    assert report.wa_occurrences.count.positive?
    aggregate_ids = "#{first_agg.id},#{bis_agg.id},#{new_agg.id}"
    aggregate_ids_ary = aggregate_ids.split(',')
    assert_raises ActiveRecord::RecordNotFound do
      # Check aggs not in report
      report.wa_aggregates.find(aggregate_ids_ary).blank?
    end
    report_ids = report.id
    # WHEN
    # calling duplicate
    post aggregates_duplicate_path, params: {
      report_ids: report_ids,
      aggregate_ids: aggregate_ids
    }
    # THEN
    # New duplicate aggregate of the ones with common occurrences only are created in report
    report.reload
    # 1 + 2
    assert_equal 3, report.wa_aggregates.count
    assert report.wa_aggregates.find_by(title: first_agg.title).present?
    assert report.wa_aggregates.find_by(title: bis_agg.title).present?
    assert report.wa_aggregates.find_by(title: new_agg.title).blank?
  end

  test 'unauthenticated cannot bulk delete aggregates' do
    aggregate_ids = ''
    delete aggregates_report_path(Report.first), params: {
      aggregate_ids: aggregate_ids
    }
    check_unauthorized
  end

  test 'authenticated staff can bulk delete aggregates if in report' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    first_agg = aggregates(:aggregate_one)
    bis_agg = aggregates(:aggregate_bis)
    aggregate_ids = "#{first_agg.id},#{bis_agg.id}"
    aggregate_ids_ary = aggregate_ids.split(',')
    # Check aggs in report
    assert report.vm_aggregates.find(aggregate_ids_ary).present?
    delete aggregates_report_path(report), params: {
      aggregate_ids: aggregate_ids
    }
    assert_raises ActiveRecord::RecordNotFound do
      # Check aggs not anymore in report
      report.vm_aggregates.find(aggregate_ids_ary).blank?
      # But only discarded
      Aggregate.with_discarded.find(aggregate_ids_ary)
    end
  end

  test 'authenticated staff cannot bulk delete aggregates if one is not in report' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    first_agg = aggregates(:aggregate_one)
    bis_agg = aggregates(:aggregate_bis)
    aggregate_ids = "#{first_agg.id},#{bis_agg.id}"
    aggregate_ids_ary = aggregate_ids.split(',')
    # Check aggs in report
    assert report.vm_aggregates.find(aggregate_ids_ary).present?
    delete aggregates_report_path(report), params: {
      aggregate_ids: "#{aggregate_ids},someshit"
    }
    # Check aggs still in report
    assert report.vm_aggregates.find(aggregate_ids_ary).present?
  end

  private

  def map_occurrences_data(occurrences, aggregate)
    occurrences.map do |occ|
      { 'aggregate_id' => aggregate.id, 'occurrence_id' => occ.id }
    end.to_json
  end
end
