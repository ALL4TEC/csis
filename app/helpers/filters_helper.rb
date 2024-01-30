# frozen_string_literal: true

module FiltersHelper
  # Surcouche à la fonction `search_form_for` de Ransack (utilise les mêmes paramètres).
  # Génère les balises utilisées pour afficher un bloc de filtres ainsi que
  # le bouton "Recherche".
  #
  # === Exemple
  #
  #   <%= ui_filters @q do |f| %>
  #     <div class="form-group">
  #       <%= f.label :full_name_cont %>
  #       <%= f.search_field :full_name_cont, class: "form-control" %>
  #     </div>
  #
  #     <div class="form-group">
  #       <%= f.label :email_cont %>
  #       <%= f.search_field :email_cont, class: "form-control" %>
  #     </div>
  #   <% end %>
  def ui_filters(*args, &block)
    render 'layouts/filters', args: args, &block
  end

  def button_content(form, &block)
    if block
      form.button :button, class: 'btn btn-primary' do
        yield block
      end
    else
      form.button :submit, class: 'btn btn-primary'
    end
  end

  # Génère un pied-de-page pour les formulaires.
  #
  # === Exemple
  #   <%= simple_form_for(...) do |f| %>
  #     <!-- All your form fields -->
  #     <%= ui_form_footer f %>
  #   <% end %>
  def ui_form_footer(form, &block)
    content_tag :div, class: 'form-footer' do
      concat button_content(form, &block)
    end
  end

  # Génère un block fixed à droite avec bouton de submit du formulaire
  #
  # === Exemple
  #   <%= simple_form_for(...) do |f| %>
  #     <!-- All your form fields -->
  #     <%= ui_fixed_form_footer f %>
  #   <% end %>
  def ui_fixed_form_footer(form, &block)
    content_tag :div, class: 'fixed-bottom d-flex justify-content-end' do
      concat button_content(form, &block)
    end
  end
end
