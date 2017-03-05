# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

def user_prompt(text, secret: false)
  STDOUT.print text
  if secret
    STDIN.noecho(&:gets).strip
  else
    STDIN.gets.strip
  end
end

def progress_bar(done, total, bar_width: 40, total_width: (ENV['COLUMNS'] || 120).to_i, detail: '')
  ratio = done.to_f / total
  line = "#{(ratio * 100).round(1)} %".rjust(8) + ' ['
  equals = (ratio * bar_width).round(0)
  line += '=' * [equals - 1, 0].max + '>' * [equals, 1].min + ' ' * (bar_width - equals) + '] ' + detail.to_s
  line = line[0...total_width].ljust(total_width)
  STDERR.print "\r#{line}"
  puts '' if done == total
end

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks
