# frozen_string_literal: true

require 'tempfile'

module TmpFileHelper
  # supprime le TMP_FILE_PATH si présent après chaque nouveau test
  def teardown
    File.delete(@tmp_file_path) if !@tmp_file_path.nil? && File.file?(@tmp_file_path)
  end

  def tmp_file_path(file_name)
    @tmp_file_path = File.join(Dir.tmpdir, file_name)
  end
end
