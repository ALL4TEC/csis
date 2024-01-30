# frozen_string_literal: true

require 'test_helper'

class Importers::Cyberwatch::AssetImportJobTest < ActiveJob::TestCase
  test 'Assets are correctly imported' do
    test_import
  end

  private

  def stub_it
    proc do |_a0, _a1, _a2|
      JSON.parse(File.read('test/fixtures/files/JobTestValues/Cyberwatch_Assets.json'))
    end
  end

  def asserts(prev, stub)
    ::Cyberwatch::Request.stub(:do_list, stub) do
      assert_equal ::Cyberwatch::Request.do_list(nil, nil, nil).class,
        Array
      targets_count = Target.count
      Importers::Cyberwatch::AssetsImportJob.perform_now(nil, CyberwatchConfig.first.id)
      assert_equal 4, Asset.count - prev
      assert_equal 4, Target.count - targets_count
    end
  end

  def test_import
    prev = Asset.count
    stub = stub_it
    asserts(prev, stub)
  end
end
