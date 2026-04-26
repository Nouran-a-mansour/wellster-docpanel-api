FROM ruby:4.0.3-slim

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev libyaml-dev

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

ENTRYPOINT ["./entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]