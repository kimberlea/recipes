class Job
  include Mongoid::Document
  include QuickJobs::Job

  quick_jobs_job!
  
  def self.update_meta_for(*models)
    models.each do |m|
      Job.run_later :meta, m, :update_meta
    end
  rescue => ex
    QuickScript.log_exception(ex)
  end

end
