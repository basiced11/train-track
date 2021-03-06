class ActionController::Response
  def <<(s)
    write(s)
  end
end

class PeopleController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :create]
  
  def index
  	hobo_index Person.fuzzy_find_scope(params[:search])
  end
 
  index_action :csv do
    csv_fields = [
      ["Region", lambda { |p| p.institution.try.region.to_s }],
	  ["School Code", lambda { |p| p.institution.try.school_code.to_s }],
	  ["Institution", lambda { |p| p.institution.try.name.to_s }],
      ["QEC", lambda { |p| p.institution.try.qec.to_s }],
	  ["BEP", lambda { |p| p.institution.try.bep || "false" }],
	  ["School Type", lambda { |p| p.institution.try.organization_type}],
      ["First Name", lambda { |p| p.first_name }],
      ["Last Name", lambda { |p| p.last_name }],
      ["Gender", lambda { |p| p.gender }],
	  ["Job", lambda {|p| p.job.try.name || "Other" }],
	  ["Job Details", lambda {|p| p.job_details }],
      ["Grade Taught", lambda { |p| p.grade_taught }],
      ["Admin", lambda { |p| p.job.try.admin || "false" }],
	  ["Cell", lambda { |p| p.cell_number }],
      ["Landline", lambda { |p| p.landline_number }],
      ["Fax", lambda { |p| p.fax_number }],
      ["Email", lambda { |p| p.email_address }]
    ]
    start_day = Date.civil(params[:start_day][:year].to_i, params[:start_day][:month].to_i, params[:start_day][:day].to_i)
    end_day = Date.civil(params[:end_day][:year].to_i, params[:end_day][:month].to_i, params[:end_day][:day].to_i)
    TrainingSubject.all.each do |ts|
      Workshop.all(:include => :workshop_sessions, :conditions => ["first_day >= ? AND last_day <= ?", start_day, end_day]).each do |w|
        if w.workshop_sessions.all(:include => :training_subject).any?{|s| s.training_subject == ts}
          csv_fields << ["%s Attended" % w.title, lambda { |p| p["w#{w.id}_attended"].try.strftime('%Y-%m-%d') }]
          csv_fields << ["%s %s Hours" % [w.title, ts.name.upcase], lambda { |p| p["w#{w.id}t#{ts.id}_minutes"]/60.0 }] 
        end
      end
      csv_fields << ["Total %s Hours" % ts.name.upcase, lambda { |p| p["t#{ts.id}_minutes"]/60.0 }]
    end
    csv_fields << ["Grand Total Hours", lambda { |p| p["total_minutes"]/60.0 }]
    
    render_csv "people.csv", csv_fields, Person.attendees_with_report_fields(start_day, end_day)
  end

end
