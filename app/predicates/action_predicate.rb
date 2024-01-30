# frozen_string_literal: true

class ActionPredicate
  class << self
    def closed?(action)
      action.clotured? || action.archived? || action.discarded?
    end

    # Vérifie si 2 actions ne sont pas dans le même "arbre de dépendances"
    def in_same_deps_tree?(current_action, other_action_id, preds = [])
      preds += Array(current_action)
      deps = current_action.action_p + current_action.action_s
      deps -= preds
      deps.all? do |act|
        act.id != other_action_id && ActionPredicate.in_same_deps_tree?(act, id, preds)
      end
    end

    # Vérifie si une action fait partie des successeurs de l'action courante
    def successor?(current_action, other_action_id)
      ActionPredicate.part_of?(current_action, other_action_id, __method__)
    end

    # Vérifie si une action fait partie des prédécesseurs de l'action courante
    def predecessor?(current_action, other_action_id)
      ActionPredicate.part_of?(current_action, other_action_id, __method__)
    end

    # Teste si les actions ont le même receiver (contact)
    # @param action_ids: les identifiants des actions ciblées
    def same_receiver?(action_ids)
      # We could have used .all? or .any? but better is comparing uniq size
      action_ids.size == 1 ? true : Action.in(action_ids).uniq(&:receiver_id).size == 1
    end

    # By default will check if action_id is part of current action successors
    # **@param action_id:**
    # **@param method:** successor? or predecessor?
    # **@return:** A boolean
    # Check that action_id is not present among current action successors or predecessors
    # nor any of one of its successors or predecessors
    def part_of?(current_action, other_action_id, method = 'successor?')
      current_action.send(:"action_#{method[0]}").all? do |dep|
        dep.id != other_action_id && ActionPredicate.send(method, dep, other_action_id)
      end
    end
  end
end
