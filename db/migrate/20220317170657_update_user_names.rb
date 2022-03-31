class UpdateUserNames < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :given_name, :string
    add_column :users, :surname, :string

    User.all.each do |user|
      next unless user.respond_to?(:display_name) && user.display_name.present?
      given_name, surname = user.display_name.split(' ')
      user.given_name = given_name
      user.surname = surname

      user.save
    end

    remove_column :users, :display_name
  end

  def down
    add_column :users, :display_name, :string

    User.all.each do |user|
      name_ary = [user.given_name, user.surname]
      next if name_ary.all?(&:blank)

      user.display_name = name_ary.join(' ')
      user.save
    end

    remove_column :users, :given_name
    remove_column :users, :surname
  end
end
