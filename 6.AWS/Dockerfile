FROM ruby:3.2
WORKDIR /rubyapp
COPY /rubyapp/Gemfile Gemfile
COPY /rubyapp/Gemfile.lock Gemfile.lock
RUN bundle install
COPY /rubyapp /rubyapp

CMD ["rails", "server", "-b", "0.0.0.0"]
