class ResetServerCounts < ActiveRecord::Migration[7.2]
  def change
    Destination.pluck(:id).each do |id|
      Destination.reset_counters(id, :servers)
    end
  end
end
