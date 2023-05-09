require 'user'
require 'database_connection'

class UserRepository
  def all
    sql = 'SELECT * FROM users;'
    result_set = DatabaseConnection.exec_params(sql, [])
    users = []
    result_set.each do |record|
      users << record_to_user_object(record)
    end
    
    return users
  end

  def find(id)
    sql = 'SELECT * FROM users WHERE id = $1;'
    result_set = DatabaseConnection.exec_params(sql, [id])
    user = record_to_user_object(result_set[0])

    return user
  end

  def create(user)
    sql = 'INSERT INTO users (email, password, name, username)
          VALUES ($1, $2, $3, $4);'
    params = [
      user.email,
      user.password,
      user.name,
      user.username
    ]

    DatabaseConnection.exec_params(sql, params)
    return nil
  end

  def find_with_peeps(id)
    sql = 'SELECT users.id,
                  users.email,
                  users.password,
                  users.name,
                  users.username,
                  peeps.id AS peep_id,
                  peeps.content,
                  peeps.time
                FROM users
                JOIN peeps
                ON peeps.user_id = users.id
                WHERE users.id = $1;'
    result_set = DatabaseConnection.exec_params(sql, [id])

    user = record_to_user_object(result_set[0])

    result_set.each do |record|
      peep_hash = {}
      peep_hash['content'] = record['content']
      peep_hash['time'] = record['time']
      user.peeps << peep_hash
    end

    return user
  end

  private

  def record_to_user_object(record)
    user = User.new
    user.id = record['id'].to_i
    user.email = record['email']
    user.password = record['password']
    user.name = record['name']
    user.username = record['username']
    return user
  end
end