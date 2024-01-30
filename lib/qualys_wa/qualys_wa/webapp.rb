# frozen_string_literal: true

class QualysWa::Webapp
  include Common::Xml

  attr_reader :id,
    :name,
    :tag_id,
    :tag_name,
    :screenshot

  def initialize(data)
    @id = get_text(data, './/id')
    @name = get_text(data, './/name')
    @screenshot = get_text(data, './/screenshot')
    tags_count = get_text(get_xpath(data, './/tags'), './/count')
    return unless tags_count.to_i >= 1

    get_xpath(data, './/Tag')&.each do |tag|
      tag_name = get_text(tag, './/name')
      tag_id = get_text(tag, './/id')
      qualys_wa_tag = ENV.fetch('QUALYS_WAS_TAG', 'CSIS_')
      qualys_wa_tag_length = qualys_wa_tag.length
      if tag_name[0..(qualys_wa_tag_length - 1)] == qualys_wa_tag
        @tag_name = tag_name[qualys_wa_tag_length..]
        @tag_id = tag_id
      end
    end
  end

  def self.get(account, webapp_id)
    api = { path: "get/was/webapp/#{webapp_id}", method: 'GET' }
    QualysWa::Request.do_singular(account, self, '//ServiceResponse', api)
  end
end
