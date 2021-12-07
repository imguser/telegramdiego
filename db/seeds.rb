if Rails.env.development?
  user = User.find_or_create_by(email: 'admin@example.com')
  user.password = user.password_confirmation = 'password'
  user.skip_confirmation! if user.respond_to?(:skip_confirmation)
  user.save
end

global = {company: 'ixGlobal'}
global.each{|k,v|GlobalSnippet.find_or_create_by(name: k, value: v)}


# telegram: /start
description = <<-DESC
Hello %{username}, welcome to %{company}!
To get started, please reply with your registered email.
You can find your email by following steps at: %{related_link}
DESC
start_command = MessageReply.find_or_create_by(name: "/start")
start_command.update_attributes(content: description, help: 'First interaction with Bot',
  related_link: 'https://www.related-link-here.com')

# telegram: /start:failed
description = <<-DESC
Hello %{username}, welcome to %{company}!
Unfortunately, there was a problem when trying to verify you.
You can try restarting your verification by hitting /verify
Please, contact support at: %{related_link}
DESC
start_command = MessageReply.find_or_create_by(name: "/start:failed")
start_command.update_attributes(content: description, help: 'Error when trying to verify user',
  related_link: 'https://www.related-link-here.com')

# telegram: /start:failed:group
start_command = MessageReply.find_or_create_by(name: "/start:failed:group")
start_command.update_attributes(content: "Please, send that to me in private. :)",
  help: 'User tries to connect to bot in a channel', quote_message: true)

# telegram: /start:group
start_command = MessageReply.find_or_create_by(name: "/start:group")
description = <<-DESC
Hello, you recently joined one of the channels owned by %{company}.
You should /verify yourself with @#{ENV['TELEGRAM_BOT_USERNAME']}.
You will be permanently banned from the channel otherwise,
and will not be able to join again until you verify with us.
DESC
start_command.update_attributes(content: description,
  help: 'User joined a channel and is not verified', private: true, use_markdown: true)

# telegram: changes
start_command = MessageReply.find_or_create_by(name: "changes")
description = <<-DESC
Hello, you have changes in access  to channels owned by %{company}.

Changes:
%{changes}
DESC
start_command.update_attributes(content: description,
  help: 'Access changes', private: true, use_markdown: true)

# telegram: interview:step1
description = <<-DESC
Hello %{username}, welcome back to %{company}!
We do not have your registered email.
Please, reply to this message with your registered email.
To cancel, hit /cancel.
DESC
start_command = MessageReply.find_or_create_by(name: "interview:step1")
start_command.update_attributes(content: description, help: 'Step 1: Ask for user ID when verifying.')

# telegram: interview:step1:short
start_command = MessageReply.find_or_create_by(name: "interview:step1:short")
start_command.update_attributes(content: "What is your email registered with us?",
  help: 'Step 2: Ask for email [short version]')

# telegram: interview:finish
description = <<-DESC
Hello %{username}, welcome back to %{company}!
You have already verified your account details.
Hit /verify if you would like to verify your account details again.
DESC
start_command = MessageReply.find_or_create_by(name: "interview:finish")
start_command.update_attributes(content: description, help: 'User already verified.')

# telegram: interview:finish:success
start_command = MessageReply.find_or_create_by(name: "interview:finish:success")
start_command.update_attributes(content: "Verified successfully.", help: 'User verification was successful')

# telegram: interview:finish:exists
start_command = MessageReply.find_or_create_by(name: "interview:finish:exists")
start_command.update_attributes(content: "User with such email already exists", help: 'Exist user')

# telegram: interview:finish:failed
description = <<-DESC
Provided Email does not match our records.
Please, /verify your verification process.
If the problem persists, please, contact support at:
%{related_link}
DESC
start_command = MessageReply.find_or_create_by(name: "interview:finish:failed")
start_command.update_attributes(content: description, help: 'User verification failed.', related_link: 'https://www.related-link-here.com')

# telegram: /cancel
start_command = MessageReply.find_or_create_by(name: "/cancel")
start_command.update_attributes(content: "Cancelled.", help: 'User cancels an action.')

# telegram: /help
description = <<-DESC
Available Commands:
/start   - verify yourself to get access to our Private Channels
/verify  - re-verify your account details from scratch
/list    - list all private channels available to me
/cancel  - cancel in-progress questionairres
/help    - this help

We are [%{company}](%{related_link}) :)
DESC
start_command = MessageReply.find_or_create_by(name: "/help")
start_command.update_attributes(content: description, help: 'help list', related_link: 'https://www.related-link-here.com', use_markdown: true)

# telegram: verification:successful
description = <<-DESC
available channels for you:

%{channel_2}
%{channel_1}
DESC
start_command = MessageReply.find_or_create_by(name: "verification:successful")
start_command.update_attributes(content: description, use_markdown: true, help: 'provide further info, e.g. list of channels, after user verifies himself successfully')

# telegram: verification:successful:no_channel
description = <<-DESC
No private channel is available to you.
Consider becoming a paid member by registering with us at:
%{related_link}
DESC
start_command = MessageReply.find_or_create_by(name: "verification:successful:no_channel")
start_command.update_attributes(content: description,
  help: 'user verified himself successfully, but channel access is not available (SKU)',
  related_link: 'https://www.related-link-here.com')

# telegram: verification:failure
description = <<-DESC
No private channel is available to you.
Please, /verify your account details with us.
Or, consider becoming a paid member by registering with us at:
%{related_link}
DESC
start_command = MessageReply.find_or_create_by(name: "verification:failure")
start_command.update_attributes(content: description,
  help: 'User could not verify himself.',
  related_link: 'https://www.related-link-here.com')

# telegram: processing
start_command = MessageReply.find_or_create_by(name: "processing")
start_command.update_attributes(content: "Processing.. Please, wait...", help: 'Processing..')

# telegram: any
start_command = MessageReply.find_or_create_by(name: "/help:short")
start_command.update_attributes(content: "Not sure what to do. Try /help", help: 'Unknown message or command. Leave blank to do nothing.')

# telegram: any
start_command = MessageReply.find_or_create_by(name: "interruption")
start_command.update_attributes(content: "To cancel previous conversation, hit /cancel.", help: 'Cancel conversation')
