class AccountRole < ApplicationRecord
  self.table_name = 'accounts_roles'

  belongs_to :account
  belongs_to :role
end