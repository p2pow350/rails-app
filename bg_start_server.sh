rm -rf log/*
RAILS_ENV=development bin/delayed_job --pool=*:10 restart
rails s -b 0.0.0.0 -d
