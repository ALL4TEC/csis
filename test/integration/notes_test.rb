# frozen_string_literal: true

require 'test_helper'

class NotesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list report notes' do
    report = scan_reports(:mapui)
    get report_notes_path(report)
    check_not_authenticated
  end

  test 'unauthenticated cannot create new report note' do
    report = scan_reports(:mapui)
    get report_new_note_path(report)
    check_not_authenticated
  end

  test 'unauthenticated cannot consult report note' do
    note = notes(:first_note)
    get note_path(note)
    check_not_authenticated
  end

  test 'unauthenticated cannot consult non-existent report note' do
    get note_path('ABC')
    check_not_authenticated
  end

  test 'unauthenticated cannot edit report note' do
    note = notes(:first_note)
    get edit_note_path(note)
    check_not_authenticated
  end

  test 'unauthenticated cannot edit non-existent report note' do
    note_id = 'ABC'
    get edit_note_path(note_id)
    check_not_authenticated
  end

  test 'unauthenticated cannot delete report note' do
    note = notes(:first_note)
    delete note_path(note)
    check_not_authenticated
    # Check that report still exists
    Note.find(notes(:first_note).id)
  end

  test 'unauthenticated cannot delete non-existent report' do
    delete note_path('ABC')
    check_not_authenticated
  end

  test 'authenticated staff can list report notes' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    get report_notes_path(report)
    assert_response :success
  end

  test 'authenticated staff can consult report note' do
    sign_in users(:staffuser)
    note = notes(:first_note)
    get note_path(note)
    assert_response :success
  end

  test 'authenticated staff cannot consult non-existent note' do
    sign_in users(:staffuser)
    get note_path('ABC')
    assert_redirected_to root_path
  end

  test 'authenticated staff can view new note form and thus create one note' do
    sign_in users(:staffuser)
    report = scan_reports(:mapui)
    get report_new_note_path(report)
    assert_response :success
    new_note = Note.find_by(title: I18n.t('notes.labels.new'))
    assert_not_nil new_note
    assert_response :success
  end

  test 'authenticated staff can display edit form for report note' do
    sign_in users(:staffuser)
    note = notes(:first_note)
    get edit_note_path(note)
    assert_response :success
  end

  test 'authenticated staff cannot display edit form for inexistent report note' do
    sign_in users(:staffuser)
    get edit_note_path('ABC')
    assert_redirected_to root_path
  end

  test 'authenticated staff can update report note' do
    sign_in users(:staffuser)
    note = notes(:first_note)
    payload = {
      id: note.id,
      title: 'Joli Scan',
      content: 'someone'
    }
    put autosave_note_path, params:
    {
      note: payload
    }
    updated = Note.find(note.id)
    assert_equal payload[:title], updated.title
    assert_equal(
      "<div class=\"trix-content\">\n  #{payload[:content]}\n</div>\n",
      updated.content.body.to_s
    )
  end

  test 'authenticated staff cannot update note without title' do
    sign_in users(:staffuser)
    note = notes(:first_note)
    put autosave_note_path, params:
    {
      note:
      {
        id: note.id,
        title: nil,
        content: 'someone'
      }
    }
    updated = Note.find(note.id)
    assert_equal note.title, updated.title
  end

  test 'authenticated staff cannot update non-existent report note' do
    sign_in users(:staffuser)
    id = 'ABC'
    title = 'fezfz'
    put autosave_note_path, params:
    {
      note:
      {
        id: 'ABC',
        title: 'fezfz',
        content: 'someone'
      }
    }
    updated = Note.find_by(title: title)
    assert_nil updated
    assert_raises ActiveRecord::RecordNotFound do
      Note.find(id)
    end
  end

  test 'authenticated staff can delete report note' do
    sign_in users(:staffuser)
    note = notes(:first_note)
    report = note.report
    delete note_path(note)
    assert_redirected_to report_notes_path(report)
    # Check that note was only discarded, not actually destroyed
    assert_not_nil Note.trashed.find(note.id)
  end

  test 'authenticated staff cannot delete non-existent report note' do
    sign_in users(:staffuser)
    delete note_path('ABC')
    assert_redirected_to root_path
  end

  test 'authenticated staff can restore discarded report note' do
    sign_in users(:staffuser)
    note = notes(:first_note)
    report = note.report
    note.discard
    put restore_note_path(note)
    assert_redirected_to report_notes_path(report)
  end

  test 'authenticated staff cannot restore non-existent discarded report note' do
    sign_in users(:staffuser)
    put restore_note_path('ABC')
    assert_redirected_to root_path
  end
end
