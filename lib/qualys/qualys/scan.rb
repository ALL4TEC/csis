# frozen_string_literal: true

class Qualys::Scan
  include Common::Xml

  attr_reader :reference,
    :client_id,
    :client_name,
    :type,
    :title,
    :user_login,
    :launched,
    :duration,
    :processed,
    :state,
    :target,
    :option_title,
    :option_flag

  def initialize(data)
    @reference = get_text(data, './/REF')
    @client_id = get_text(get_xpath(data, './/CLIENT'), './/ID')
    @client_name = get_text(get_xpath(data, './/CLIENT'), './/NAME')
    @type = get_text(data, './/TYPE')
    @title = get_text(data, './/TITLE')
    @user_login = get_text(data, './/USER_LOGIN')
    @launched = Time.zone.parse(get_text(data, './/LAUNCH_DATETIME'))
    @duration = get_text(data, './/DURATION')
    @processed = get_text(data, './/PROCESSED')
    @state = get_text(get_xpath(data, './/STATUS'), './/STATE')
    @target = get_text(data, '//TARGET')
    options = get_xpath(data, './/OPTION_PROFILE')
    @option_title = get_text(options, './/TITLE')
    @option_flag = get_text(options, './/DEFAULT_FLAG')
  end

  def self.list(account, opts = {})
    opts[:action] = 'list'
    opts[:state] = 'Canceled,Finished,Error'
    Qualys::Request.do_list(account, self, '//SCAN', 'scan/', opts)
  end

  def self.get(account, reference)
    opts = { action: 'list', scan_ref: reference }
    Qualys::Request.do_singular(account, self, '//SCAN', 'scan/', opts)
  end
end
