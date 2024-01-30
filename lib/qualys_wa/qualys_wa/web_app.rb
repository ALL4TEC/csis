# frozen_string_literal: true

class QualysWa::WebApp
  include Common::Xml

  attr_reader :id,
    :name,
    :url

  def initialize(data)
    @id = get_text(data, './/id')
    @name = get_text(data, './/name')
    @url = get_text(data, './/url')
  end
end
