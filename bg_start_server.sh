rm -rf log/*
RAILS_ENV=development bin/delayed_job restart
rails s -b 0.0.0.0 -d
