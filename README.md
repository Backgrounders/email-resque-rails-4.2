# README
by [Sunny Mittal](http://www.sunnymittal.com)
## Introduction
This is a basic, horrible-looking rails app that demonstrates how to send mail using background jobs with Resque and ActiveJob in Rails 4.2 so that your users aren't left waiting for the request-response cycle to complete.

## Rails
- version 4.2

## Pre-requisites

### Install Redis

Mac Users:
```console
$ brew install redis
```

Linux Users:
```console
$ wget http://download.redis.io/releases/redis-2.8.17.tar.gz
$ tar xzf redis-2.8.17.tar.gz
$ cd redis-2.8.17
$ make
```

After installing, I added the `src` directory to my path, but that's up to you.

## Getting Started
First create your rails app:

```
$ rails new mailer_app
```

Next add the Resque gems to your `Gemfile` and `bundle install`:

```ruby
gem 'resque'
gem 'resque-scheduler'
````
```console
$ bundle install
```

Now let's add the necessary configuration to our `development.rb` file.

Note: I chose to use Gmail as my client and have my username and password set up as environment variables.

```ruby
# config/environments/development.rb
config.active_job.queue_adapter = :resque
config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'google.com',
  user_name:            ENV['GMAIL_USERNAME'],
  password:             ENV['GMAIL_PASSWORD'],
  authentication:       'plain',
  enable_starttls_auto: true }
```

### The UserMailer

Now we need to generate the user mailer:

```console
rails generate mailer UserMailer
```

In the generated file (`app/mailers/user_mailer.rb`), add any defaults you wish along with your message to yourself from your users:

```ruby
class UserMailer < ActionMailer::Base
  default to: 'your-email-here@example.com'

  def comments_email(user)
    @user = user
    mail(from: @user.email, subject: 'your-subject-here')
  end
end
```

We create an instance variable so that it can be accessible in our mailer views (analogous to a controller and its views). Also be sure that your method is suffixed with `_email`.

### The Mailer View

Now we create a file in our `app/views/user_mailer` folder with the snake-cased name of our method. In my case, this is `comments_mailer.html.erb`. This is the markup file for your email so add any HTML you choose and save the file. This is also the place to add the content of your user's comments so be sure to have `<%= @user.content %>` somewhere!


### Users Controller, User Model, and Users Migration

For simplicity, let's use the scaffold generator to create our model, controller, and migration. The model and migration are not necessarily needed, but it may be good to save a user's comments in a database in case the email doesn't go through.

```console
$ rails generate scaffold User name email content:text
$ rake db:migrate
```

### Creating the Send Email Job

Now that we've set up the majority of our app, it's time to create the job that we wish to run in the background. Run the following from your terminal:

```console
rails generate job SendEmail
```

This will generate a `send_email_job.rb` file in a new `app/jobs` folder. Open the file and modify it as follows:

```ruby
class SendEmailJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    UserMailer.comments_email(user).deliver
  end
end
```

The `queue_as` method takes a number of parameters, which would best be reviewed and understood from the Rails documentation. I chose to leave it at default as sending an email is not a job I cared to prioritize. The job, which you'll notice inherits from `ActiveJob::Base` requires a `perform` method and can take in whatever parameters you choose. Since this is an email job pertaining to a particular user, I passed in a `user` parameter. In this method, we simply call the job to be queued. In our case, it's delivering the comments email, which we call using `UserMailer.comments_email(user).deliver`.

### Final Step!

Now that we've scaffolded the application and created the files we need to queue a job, what the hell else is there to do?! Oh yeah, we have to queue the job! In your controller, remove all the methods the scaffolding created except 'index' and 'new' (for this simple app, we don't care to update, delete, or show users). We want the 'index' view to display all users who have sent us an email, so in the controller, we find all users using `@users = User.all`. In the 'index' view we then iterate through the users and show whatever information we want (be sure to remove the 'show', 'edit' and 'destroy') links that were created by the scaffolding. I also renamed the button because I'm not creating a new user in my example, just allowing a user to suggest something or make comments. Adjust the fields in the `new` view as desired and be sure to permit any attributes you need in the controller. Lastly, we need to queue our email job after the user's entry is saved, so we simply call `SendEmailJob.new.perform(@user)` in the 'create' method to instantiate a new emal job and simultaneously ask it to perform its designated action, taking '@user' as the parameter. And that's all there is to it! The user will be redirected (or whatever you choose their fate to be) and have no idea as to when (or if!) their comments were sent to you. :)
