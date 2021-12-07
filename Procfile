web: bundle exec rails server -p ${PORT:-5000} -e ${RAILS_ENV:-development}
worker: bundle exec sidekiq -t 25 -c 3