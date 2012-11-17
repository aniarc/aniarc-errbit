class NotificationServices::AniarcBotService < NotificationService
  Label = "aniarc_bot"
  Fields = [
      [:api_token, {
          :placeholder => "HTTP Server URL:Port",
          :label => "http://example.com:12345"
      }]
  ]

  def check_params
    if Fields.detect {|f| self[f[0]].blank? }
      errors.add :base, 'You must specify your User Key and Application API Token.'
    end
  end

  def url
    "https://github.com/aniarc/"
  end

  def create_notification(problem)
    require 'rest_client'

    RestClient.post api_token, {
        :app => problem.app.name,
        :env => problem,#.environment_name,
        :hostname => problem.server_environment['hostname'],
        :msg => notification_description(problem),
        :where => problem.where,
        :errbit_url => "http://#{Errbit::Config.host}/apps/#{problem.app.id.to_s}"
    }
  end
end
