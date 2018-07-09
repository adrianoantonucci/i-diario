class WorkerBatch < ActiveRecord::Base

  belongs_to :stateable, polymorphic: true

  def all_workers_finished?
    total_workers == done_workers
  end

  def done_percentage
    return 0 if total_workers == 0

    ((done_workers.to_f / total_workers.to_f) * 100).round(0)
  end

  def self.increment(worker_batch_id, done_info)
    worker_batch = WorkerBatch.find(worker_batch_id)
    worker_batch.increment(done_info) do
      yield if block_given?
    end
  end

  def increment(done_info)
    with_lock do
      update_attributes!(
        done_workers: (done_workers + 1),
        completed_workers: (completed_workers << done_info)
      )

      yield if block_given? && all_workers_finished?
    end
  end
end
