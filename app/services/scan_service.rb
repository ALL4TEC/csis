# frozen_string_literal: true

class ScanService
  class << self
    # Add new_scans in scans function of index
    def handle_ar_collection_merge(scans, new_scans, index)
      if index.zero?
        scans = new_scans
      else
        scans.merge(new_scans)
      end
      scans
    end

    #### FOR PROJECTS USABLE SCANS ####
    # project.usable_#{kind}_scans = all scans in common between teams linked to project
    # + manually imported

    # @param **teams:** Teams to fetch scans from
    # @param **kind:** Kind of scan (vm|wa)
    # @return Available scanner accounts scans (QualysConfig + Cyberwatch) in common between
    # teams as a ActiveRecord::Associations::CollectionProxy
    # For each team
    #   For each common qualys account
    #     If any client ? then all common clients
    #     Else account
    def common_accounts_scans_between_teams(teams, kind)
      all_accounts = teams.flat_map(&:accounts).uniq
      common_accounts = all_accounts.select do |account|
        teams.all? { |team| account.id.in?(team.accounts.ids) }
      end
      scans = []
      common_accounts.each_with_index do |account, index|
        new_scans = send(
          :"common_#{account.type.underscore}_scans_between_teams", account, teams, kind
        )
        scans = handle_ar_collection_merge(scans, new_scans, index)
      end
      scans
    end

    # @param **potentially_common_qualys_clients:** Potentially common Qualys clients
    # @param **teams:** Compared teams
    # @param **kind:** Scan kind
    # @return **Scans linked to common qualys client between teams**
    # For each potentially_common_qualys_clients
    #   If all teams linked to client
    #     then select all scans attached to qualys_#{kind}_client
    #   Else select nothing
    def select_common_qualys_clients_scans(potentially_common_qualys_clients, teams, kind)
      scans = []
      potentially_common_qualys_clients.each_with_index do |qualys_client, index|
        next unless teams.all? { |team| team.in?(qualys_client.teams) }

        new_scans = qualys_client.send(:"#{kind}_scans")
        scans = handle_ar_collection_merge(scans, new_scans, index)
      end
      scans
    end

    # @param **account:** Qualys account
    # @param **teams:** Compared teams
    # @param **kind:** Scans kind
    # @return Qualys scans of kind in common between teams
    def common_qualys_config_scans_between_teams(account, teams, kind)
      account_qualys_clients = account.send(:"qualys_#{kind}_clients")
      teams_qualys_clients = teams.flat_map(&:"qualys_#{kind}_clients")
      potentially_common_qualys_clients = (account_qualys_clients & teams_qualys_clients)
      # If any client linked to a team => # select only scans linked to common clients
      if potentially_common_qualys_clients.present?
        select_common_qualys_clients_scans(potentially_common_qualys_clients, teams, kind)
      else
        # Else select all scans linked to account
        account.send(:"#{kind}_scans")
      end
    end

    # @param **account:** Cyberwatch account
    # @param **teams:** Compared teams
    # @param **kind:** Scans kind
    # @return Cyberwatch scans of kind in common between teams
    def common_cyberwatch_config_scans_between_teams(account, _teams, kind)
      # return all scans linked to account
      account.send(:"#{kind}_scans")
    end

    #### FOR USERS ####

    # @param **user:** User to list visible by scans
    # @param **kind:** Scans kind
    # @return **all visible scans ids array by user**
    # For each team
    #   For each account
    #     If all client ? then all scans with client
    #     Else all scans attached to account
    def visible_accounts_scans_ids(user, kind)
      # Filter all scanner accounts linked to user.staff_teams
      only_active_scanners = AccountLambda.only_active_scanners_of_kind(kind)
      all_accounts = user.staff_teams.flat_map(&:accounts).uniq.select(&only_active_scanners)
      scan_ids = []
      all_accounts.each do |account|
        new_scans = send(:"visible_#{account.type.underscore}_scans_ids", account, user, kind)
        scan_ids += new_scans
      end
      scan_ids
    end

    # @param **account:** Qualys account
    # @param **user:** User to return scans visible by
    # @param **kind:** Scans kind
    # @return All scans of kind visible by user for qualys account
    def visible_qualys_config_scans_ids(account, user, kind)
      teams = user.staff_teams
      qualys_clients = account.send(:"qualys_#{kind}_clients")
      qualys_clients_linked_to_all_teams = qualys_clients.select do |qualys_client|
        teams.all? { |team| team.in?(qualys_client.teams) }
      end
      scans = []
      if qualys_clients_linked_to_all_teams.present?
        # If all teams linked to an account client then select only scans linked to client
        qualys_clients_linked_to_all_teams.each_with_index do |qualys_client, index|
          new_scans = qualys_client.send(:"#{kind}_scans")
          scans = handle_ar_collection_merge(scans, new_scans, index)
        end
      else
        # Else select scans linked to account
        scans = account.send(:"#{kind}_scans")
      end
      scans.present? ? scans.ids : []
    end

    # No perimeter notion for cyberwatch so all scans of an account are
    # visible for all related team members
    # Thus VmScans only
    def visible_cyberwatch_config_scans_ids(account, _user, kind)
      account.send(:"#{kind}_scans").ids
    end
  end
end
