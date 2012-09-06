class AuditLogEntry < ActiveRecord::Base
  belongs_to :user
  # TODO
  #belongs_to :auditable, :polymorphic => true
end
