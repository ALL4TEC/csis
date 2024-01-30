# frozen_string_literal: true

class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, except: %i[edit destroy restore autosave]
  before_action :set_whodunnit
  before_action :set_report, only: %i[index new]
  before_action :set_notes, only: %i[index]
  before_action :set_note, only: %i[show edit destroy]
  before_action :set_trashed_note, only: %i[restore]
  before_action :set_note_autosave, only: %i[autosave]
  before_action :authorize_note!, only: %i[edit destroy restore autosave]
  before_action :set_collection_section_header, only: %i[index]
  before_action :set_member_section_header, only: %i[show]

  # Override CSP config only for statistics page due to chart.js styling ...
  content_security_policy only: %i[new edit] do |policy|
    policy.style_src :self, :https, :unsafe_inline
  end

  def index
    list_notes
  end

  def show
    common_breadcrumb
    add_breadcrumb @note.title
  end

  def new
    @note = Note.new
    @note.title = I18n.t('notes.labels.new')
    @note.author = current_user
    @note.report = @report
    @note.save
    new_data
    render 'edit'
  end

  def edit
    edit_data
  end

  def autosave
    # Set note from hidden id form field i.e. note[:id]
    status = @note.update(note_params) ? :ok : :bad_request
    head status
  end

  def destroy
    @note.discard
    notice = t(
      'notes.notices.deleted_html',
      note: html_escape_once(@note.title),
      cancel: helpers.link_to(
        t('notes.actions.restore'),
        restore_note_path(@note),
        method: :put,
        data: {
          confirm: t(
            'notes.actions.restore_confirm',
            infos: html_escape_once(@note.title)
          )
        }
      )
    )
    redirect_to report_notes_path(@note.report), notice: notice
  end

  def restore
    @note.undiscard
    redirect_to(
      report_notes_path(@note.report),
      notice: t('notes.notices.restored', note: @note.title)
    )
  end

  private

  def authorize!
    authorize(Note)
  end

  def authorize_note!
    authorize(@note)
  end

  def common_breadcrumb
    add_home_to_breadcrumb
    report = @report.presence || @note.report
    add_breadcrumb t('projects.section_title'), :projects_url
    add_breadcrumb report.project.name, project_path(report.project_id)
    add_breadcrumb t('models.reports'), project_reports_path(report.project_id)
    add_breadcrumb report.title, report
    add_breadcrumb t('notes.section_title'), report_notes_path(report)
  end

  def list_notes
    common_breadcrumb
    add_breadcrumb t('scopes.trashed') unless caller_locations(1..1).first.label == 'index'
    @q_base = @notes
    @q = @q_base.ransack params[:q]
    @q.sorts = ['title asc']
    @notes = @q.result.page(params[:page]).per(params[:per_page])
  end

  def new_data
    common_breadcrumb
    add_breadcrumb t('notes.actions.create')
    @app_section = make_section_header(
      title: t('notes.actions.create'),
      actions: [NotesHeaders.new.action(:back, report_notes_path(@report))]
    )
  end

  def edit_data
    note = Note.find(@note.id)
    common_breadcrumb
    add_breadcrumb note.title, note_path(@note)
    add_breadcrumb "#{t('notes.actions.edit')} #{note.title}"
    @app_section = make_section_header(
      title: t('notes.pages.edit', note: note.title),
      actions: [NotesHeaders.new.action(:back, report_notes_path(@note.report))]
    )
  end

  def note_params
    params.require(:note).permit(policy(Note).permitted_attributes)
  end

  def set_report
    handle_unscoped { @report = policy_scope(Report).find(params[:report_id]) }
  end

  def set_note
    handle_unscoped { @note = policy_scope(Note).find(params[:id]) }
  end

  def set_note_autosave
    handle_unscoped { @note = policy_scope(Note).find(params[:note][:id]) }
  end

  def set_notes
    store_request_referer(report_path(@report))
    @notes = @report.notes.includes([:author])
  end

  def set_trashed_note
    handle_unscoped { @note = policy_scope(Note).trashed.find(params[:id]) }
  end

  def set_collection_section_header
    # For quick actions
    @headers = NotesHeaders.new
    clazz = @report.class
    reports_headers = "#{clazz}sHeaders".constantize.new
    headers = policy_headers(clazz, :member).filter
    @app_section = make_section_header(
      title: t('reports.pages.title', report: @report.title,
        date: @report.edited_at.strftime('%d/%m/%y')),
      subtitle: t('reports.pages.project', project: @report.project,
        client: @report.project.client),
      scopes: reports_headers.tabs(headers[:tabs], @report),
      actions: reports_headers.actions(%i[create_note] | headers[:actions], @report),
      other_actions: reports_headers.actions(headers[:other_actions] - %i[create_note], @report),
      filter_btn: true
    )
  end

  def set_member_section_header
    notes_headers = NotesHeaders.new
    headers = policy_headers(:note, :member, @note).filter
    @app_section = make_section_header(
      title: @note.title,
      actions: notes_headers.actions(headers[:actions], @note),
      other_actions: notes_headers.actions(headers[:other_actions], @note),
      scopes: notes_headers.tabs(headers[:tabs], @note)
    )
  end
end
