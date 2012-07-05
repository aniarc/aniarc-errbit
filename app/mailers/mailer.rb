# Haml doesn't load routes automatically when called via a rake task.
# This is only necessary when sending test emails (i.e. from rake hoptoad:test)
require Rails.root.join('config/routes.rb')

class Mailer < ActionMailer::Base
  default :from => Errbit::Config.email_from

  def err_notification(notice)
    require 'rest_client'
    @notice   = notice
    @app      = notice.app

    begin
      RestClient.post 'http://sc.qarp.org:58123', { 
        :app_name => @app.name,
        :notice_message => @notice.message,
        :notice => notice
      }
    rescue
      logger.debug "RestClient Error #{$!}"
    end

    mail :to      => @app.notification_recipients,
    :subject => "[#{@app.name}][#{@notice.environment_name}] #{@notice.message}"

  end

  def deploy_notification(deploy)
    @deploy   = deploy
    @app  = deploy.app

    mail :to       => @app.notification_recipients,
         :subject  => "[#{@app.name}] Deployed to #{@deploy.environment} by #{@deploy.username}"
  end
end

