# frozen_string_literal: true

module GroupsHelper
  def group_name(name)
    t("groups.#{name}")
  end
end
