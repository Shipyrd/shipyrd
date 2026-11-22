class DestinationDeployState
  COMMANDS = %w[deploy setup].freeze
  POST_DEPLOY = "post-deploy".freeze

  def self.preload(destinations)
    new(destinations.to_a).preload
  end

  def initialize(destinations)
    @destinations = destinations
  end

  def preload
    @destinations.each do |destination|
      key = [destination.application_id, destination.name]

      destination.latest_deploy = attach(deploys[latest_deploy_ids[key]], destination)
      destination.latest_post_deploy = attach(deploys[latest_post_deploy_ids[key]], destination)

      latest = destination.latest_deploy
      latest.previous_deploy = attach(preceding_post_deploy_for(latest), destination) if latest
    end

    @destinations
  end

  private

  def attach(deploy, destination)
    deploy.application = destination.application if deploy
    deploy
  end

  def preceding_post_deploy_for(deploy)
    key = [deploy.application_id, deploy.destination]
    newest = latest_post_deploy_ids[key]

    deploys[(deploy.id == newest) ? preceding_post_deploy_ids[key] : newest]
  end

  def latest_deploy_ids
    @latest_deploy_ids ||= group_newest(deploy_scope)
  end

  def latest_post_deploy_ids
    @latest_post_deploy_ids ||= group_newest(post_deploy_scope)
  end

  def preceding_post_deploy_ids
    @preceding_post_deploy_ids ||= begin
      newest = latest_post_deploy_ids.values

      newest.empty? ? {} : group_newest(post_deploy_scope.where.not(id: newest))
    end
  end

  def deploys
    @deploys ||= begin
      ids = (latest_deploy_ids.values + latest_post_deploy_ids.values + preceding_post_deploy_ids.values).uniq

      ids.empty? ? {} : Deploy.where(id: ids).index_by(&:id)
    end
  end

  def group_newest(scope)
    scope.group(:application_id, :destination).maximum(:id)
  end

  def post_deploy_scope
    deploy_scope.where(status: POST_DEPLOY)
  end

  def deploy_scope
    Deploy.where(application_id: application_ids, command: COMMANDS)
  end

  def application_ids
    @application_ids ||= @destinations.filter_map(&:application_id).uniq
  end
end
