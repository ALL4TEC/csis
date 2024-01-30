# frozen_string_literal: true

# ----------------------------------------
# :section: Inuit.rb
# Utilitaires pour la gestion de l'interface utilisateur de Coeur SI.
# ----------------------------------------

module Inuit
  # +SectionHeader+ est utilisé pour représenter de manière uniforme l'en-tête des différentes
  # pages de Coeur SI. Il se charge de la gestion et de l'affichage du titre de la page, du
  # sous-titre de la page, des actions spécifiques à la page et des onglets.
  class SectionHeader
    include ::ActionView::Helpers::UrlHelper

    attr_reader :title,
      :help,
      :subtitle_href,
      :actions,
      :other_actions,
      :scopes,
      :filter_btn

    # Constructeur de +SectionHeader+
    #
    # === Params
    #
    # +request+:: La requête HTTP actuelle
    # +opts+:: Les différentes options de l'en-tête (cf. les paramètres suivants)
    # +title+:: Le titre principal de la page
    # +help+:: Indique si un bouton avec une icône d'aide permettant d'ouvrir un offcanvas est
    # disponible
    # +subtitle+:: Le sous-titre de la page, peut-être un lien (cf Inuit::Link,
    #              Inuit::ExternalLink, et Inuit::MailLink)
    # +actions+:: Une liste d'actions affichées dans l'en-tête
    # +other_actions+:: Une liste d'actions, cachées dans un menu déroulant
    # +scopes+:: Les différents onglets à afficher dans l'en-tête. Un onglet est un dictionnaire
    #            contenant les clés +label+ et +href+. L'onglet actuel est automatiquement
    #            déterminé à partir de l'URL de la requête donnée. Chaque onglet peut redéfinir les
    #            attributs +subtitle+, +actions+ et +other_actions+.
    # +filter_btn+:: Boolean to display or not filter button
    def initialize(request, opts)
      @request = request
      defaults = {
        title: nil,
        help: nil,
        subtitle: nil,
        actions: [],
        other_actions: [],
        scopes: [],
        filter_btn: false
      }
      merged = defaults.merge(opts)
      @title = merged[:title]
      @help = merged[:help]
      @subtitle = merged[:subtitle]
      @actions = merged[:actions].map do |action|
        action[:method] ||= :get
        action[:data] ||= nil
        action
      end
      @other_actions = merged[:other_actions].map do |action|
        action[:method] ||= :get
        action[:data] ||= nil
        action
      end
      @scopes = merged[:scopes]
      @filter_btn = merged[:filter_btn]
    end

    def subtitle
      current_scope = @scopes.find { |scope| current_page?(scope[:href]) }
      if current_scope.nil? || current_scope[:subtitle].nil?
        @subtitle
      else
        current_scope[:subtitle]
      end
    end

    private

    attr_reader :request
  end

  # Un lien vers une page hypertexte.
  #
  # La méthode to_s[Inuit::Link#to_s] a été surchargée pour simplifier la manipulation de l'objet.
  #
  # === Params
  #
  # +text+:: Le texte du lien affiché à l'utilisateur
  # +href+:: L'URL de destination du lien
  # +opts+:: Un dictionnaire utilisé pour rajouter des attributs à la balise +a+ générée
  class Link
    include ::ActionView::Helpers::UrlHelper

    def initialize(text, href, opts = {})
      @text = text
      @href = href
      @opts = opts
    end

    def to_s
      link_to(@text, @href, @opts)
    end
  end

  # Un lien vers une page hypertexte.
  #
  # Les attributs +target="_blank"+ et +rel="noopener noreferrer"+ sont rajoutés de manière à ce
  # que le lien soit ouvert dans un nouvel onglet.
  #
  # *NOTE* : les attributs +target+ et +rel+ sont forcés par la classe +ExternalLink+ et ne peuvent
  # pas être surchargé par l'utilisateur.
  #
  # La méthode to_s[Inuit::ExternalLink#to_s] a été surchargée pour simplifier la manipulation de
  # l'objet.
  #
  # === Params
  #
  # +text+:: Le texte du lien affiché à l'utilisateur
  # +href+:: L'URL de destination du lien
  # +opts+:: Un dictionnaire utilisé pour rajouter des attributs à la balise +a+ générée
  class ExternalLink
    include ::ActionView::Helpers::UrlHelper

    def initialize(text, href, opts = {})
      @text = text
      @href = href
      @opts = opts
      @opts[:target] = '_blank'
      @opts[:rel] = 'noopener noreferrer'
    end

    def to_s
      link_to(@text, @href, @opts)
    end
  end

  # Un lien vers une adresse email
  #
  # Le lien est préfixé par +mailto:+ de manière à ce que l'adresse email soit correctement
  # interprétée par les navigateurs.
  #
  # La méthode to_s[Inuit::MailLink#to_s] a été surchargée pour simplifier la manipulation de
  # l'objet.
  #
  # === Params
  #
  # +text+:: Le texte du lien affiché à l'utilisateur
  # +href+:: L'URL de destination du lien
  # +opts+:: Un dictionnaire utilisé pour rajouter des attributs à la balise +a+ générée
  class MailLink
    include ::ActionView::Helpers::UrlHelper

    def initialize(text, email, opts = {})
      @text = text
      @email = email
      @opts = opts
    end

    def to_s
      link_to(@text, "mailto:#{@email}", @opts)
    end
  end
end
