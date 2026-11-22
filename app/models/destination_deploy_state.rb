# Loads the deploy records a destination row reads — the latest deploy, the
# latest post-deploy behind `on_deck_url`, and the post-deploy before it behind
# `compare_url` — for a whole collection of destinations at once.
#
# Rendered a destination at a time those are four queries each, and they are
# invisible to Bullet: `Destination#latest_deploy` and friends are scoped
# `deploys.where(...)` calls rather than association reads, so nothing warns as
# the count grows. Both the dashboard index and the applications JSON index
# render every destination of every application, so the cost grew with the
# number of destinations. This takes four queries no matter how many there are.
class DestinationDeployState
  COMMANDS = %w[deploy setup].freeze
  POST_DEPLOY = "post-deploy".freeze

  # Returns the destinations given, with their deploy state filled in.
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

  # `Deploy#compare_url` reads `application.repository_url`. The application is
  # already in hand, so hand it over rather than letting each deploy load its
  # own — and rather than eager loading an association most of these deploys
  # never read, which Bullet would flag as unused.
  def attach(deploy, destination)
    deploy.application = destination.application if deploy
    deploy
  end

  # What `Deploy#previous_deploy` resolves to for the destination's latest
  # deploy: the newest post-deploy that is not the deploy itself.
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

  # `.last` on an unordered relation is the highest id, which is what
  # `Destination#latest_deploy` and `Deploy#previous_deploy` both select.
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
