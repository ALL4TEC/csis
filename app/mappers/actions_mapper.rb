# frozen_string_literal: true

class ActionsMapper
  class << self
    # @param **name:** Aggregate name
    # @param **report:** Report
    # @param **aggregates:** Report organizational aggregates
    # @return a hash built with provided data
    def aggregate_h(name, report, aggregates)
      {
        title: name,
        report_id: report.id,
        rank: aggregates.count + 1,
        kind: 'organizational',
        status: 'vulnerability_or_potential_vulnerability',
        severity: 'trivial'
      }
    end

    # @param **row:** CSV row
    # @param **selected_aggregate:** Selected aggregate
    # @param **current_user:** Current user
    # @return a hash built with provided data
    def action_h(row, selected_aggregate, current_user)
      hash = {
        name: row[0],
        state: row['state'],
        meta_state: row['meta_state'],
        aggregate_ids: selected_aggregate.id,
        author_id: current_user.id,
        priority: row['priority']
      }
      hash[:created_at] = row['created_at'] if row['created_at'].present?
      hash[:due_date] = row['due_date'] if row['due_date'].present?
      hash[:pmt_name] = row['pmt_name'] if row['pmt_name'].present?
      hash
    end
  end
end
