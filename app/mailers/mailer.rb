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
      RestClient.post Errbit::Config.post_to, {
        :app => @app.name,
        :env => @notice.environment_name,
        :hostname => @notice.server_environment['hostname'],
        :msg => @notice.message,
        :where => @notice.where,
        :url => @notice.request['url'],
        :errbit_url => app_err_url(@app, @notice.problem)
      }
    rescue
      logger.debug "RestClient Error #{$!}"
    end

    mail :to      => @app.notification_recipients,
    :subject => "[#{@app.name}][#{@notice.server_environment['hostname']}] #{@notice.message}"

  end

  def deploy_notification(deploy)
    @deploy   = deploy
    @app  = deploy.app

    mail :to       => @app.notification_recipients,
         :subject  => "[#{@app.name}] Deployed to #{@deploy.environment} by #{@deploy.username}"
  end
end

