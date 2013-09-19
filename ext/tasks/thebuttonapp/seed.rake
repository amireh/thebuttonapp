namespace :thebuttonapp do
  desc "seeds the given user with some random data for testing"
  task :seed_user => :environment do |t, args|
    puts User.create({
      name: 'Ahmad Amireh',
      email: 'ahmad@amireh.net',
      password:               User.encrypt('moo123'),
      password_confirmation:  User.encrypt('moo123'),
      provider: 'algol'
    }).inspect
  end
end
