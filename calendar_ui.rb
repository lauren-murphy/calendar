require 'bundler/setup'
Bundler.require(:default)

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

database_configuration = YAML::load(File.open('./db/config.yml'))
development_configuration = database_configuration["development"]
ActiveRecord::Base.establish_connection(development_configuration)

def main_menu
  choice = nil
  until choice == 'x'
    puts "*******************************"
    puts "WELCOME TO THE CALENDAR!"
    puts "Press 'c' to create a new event in your calendar"
    puts "Press 'vf' to view all future events chronologically"
    puts "Press 'vc' to view events for a chosen time period"
    puts "Press 'd' to delete an event from the calendar"
    puts "Press 'e' to edit an existing event in the calendar"
    puts "Press 'x' to exit the calendar app"
    puts "*******************************"
    choice = gets.chomp.downcase
    case choice
    when 'c'
      create_event
    when 'vf'
      view_future_events
    when 'vc'
      view_chosen_events
    when 'd'
      system "clear"
      delete_event
    when 'e'
      system "clear"
      edit_event
    when 'x'
      puts "Goodbye"
      exit
    else
      puts "Invalid input"
      main_menu
    end
  end
end

def create_event
  puts "What is the name of the event?"
  description = gets.chomp
  puts "Where is the event happening?"
  location = gets.chomp
  puts "Enter the start date (YYYY-MM-DD)"
  start_date = gets.chomp
  puts "Enter the end date (YYYY-MM-DD)"
  end_date = gets.chomp
  puts "Enter the start time (00:00) millitary time only please"
  start_time = gets.chomp
  puts "Enter the end time (00:00) millitary time only please"
  end_time = gets.chomp
  the_start = start_date + "," + start_time
  the_end = end_date + "," + end_time
  event = Event.create({
    :description => description,
    :location => location,
    :start => the_start,
    :end => the_end
    })
  puts "#{event.description} has been created!"
end

def view_future_events
  system "clear"
  future_events = []
  Event.all.order(:start).each do |event|
    if event.start > Time.now
      future_events << event
    end
  end
  puts "Your future events:"
  puts "*******************"
  future_events.each_with_index do |event, index|
    puts "\n#{index+1}) **#{event.description.capitalize}**"
    puts "At #{event.location}"
    if event.start.strftime("%m/%d/%Y") == event.end.strftime("%m/%d/%Y")
      puts "On #{event.start.strftime("%m/%d/%Y")} #{event.start.strftime(" from %I:%M%p")} #{event.end.strftime(" until %I:%M%p")}"
    else
      puts "On #{event.start.strftime("%m/%d/%Y")} #{event.start.strftime(" from %I:%M%p")} #{event.end.strftime(" until %I:%M%p")} ending #{event.end.strftime("%m/%d/%Y")}"
    end
  end
  puts "\n"
end

def view_chosen_events
  puts "Press 'm' to view all of this month's events"
  puts "Press 'w' to view all of this week's events"
  puts "Press 'd' to view all of today's events"
  puts "Press 'x' to return to the main menu"
  input = gets.chomp.downcase
  case input
  when 'm'
    system "clear"
    view_month_events
  when 'w'
    system "clear"
    view_week_events
  when 'd'
    system "clear"
    view_day_events
  when 'x'
    main_menu
  end
end

def view_month_events
  now = Time.now
  month_events = []
  Event.all.order(:start).each do |event|
    if event.start.month == now.month && event.start.year == now.year
      month_events << event
    end
  end
  puts "This months events:"
  puts "*******************"
  month_events.each_with_index do |event, index|
    puts "\n#{index+1}) **#{event.description.capitalize}**"
    puts "At #{event.location}"
    if event.start.strftime("%m/%d/%Y") == event.end.strftime("%m/%d/%Y")
      puts "On #{event.start.strftime("%m/%d/%Y")} #{event.start.strftime(" from %I:%M%p")} #{event.end.strftime(" until %I:%M%p")}"
    else
      puts "On #{event.start.strftime("%m/%d/%Y")} #{event.start.strftime(" from %I:%M%p")} #{event.end.strftime(" until %I:%M%p")} ending #{event.end.strftime("%m/%d/%Y")}"
    end
  end
end

def view_week_events
  now = Time.now
  weeks_events = []
  Event.all.order(:start).each do |event|
    day = event.start.yday+2
    if day/7 == now.yday/7 && event.start.year == now.year
      weeks_events << event
    end
  end
  binding.pry
  puts "This weeks events:"
  puts "*******************"
  weeks_events.each_with_index do |event, index|
    puts "\n#{index+1}) **#{event.description.capitalize}**"
    puts "At #{event.location}"
    if event.start.strftime("%m/%d/%Y") == event.end.strftime("%m/%d/%Y")
      puts "On #{event.start.strftime("%m/%d/%Y")} #{event.start.strftime(" from %I:%M%p")} #{event.end.strftime(" until %I:%M%p")}"
    else
      puts "On #{event.start.strftime("%m/%d/%Y")} #{event.start.strftime(" from %I:%M%p")} #{event.end.strftime(" until %I:%M%p")} ending #{event.end.strftime("%m/%d/%Y")}"
    end
  end
end

def view_day_events
  now = Time.now
  today_events = []
  Event.all.order(:start).each do |event|
    if event.start.yday == now.yday && event.start.year == now.year
      today_events << event
    end
  end
  puts "Today's events:"
  puts "*******************"
  today_events.each_with_index do |event, index|
    puts "\n#{index+1}) **#{event.description.capitalize}**"
    puts "At #{event.location}"
    if event.start.strftime("%m/%d/%Y") == event.end.strftime("%m/%d/%Y")
      puts "On #{event.start.strftime("%m/%d/%Y")} #{event.start.strftime(" from %I:%M%p")} #{event.end.strftime(" until %I:%M%p")}"
    else
      puts "On #{event.start.strftime("%m/%d/%Y")} #{event.start.strftime(" from %I:%M%p")} #{event.end.strftime(" until %I:%M%p")} ending #{event.end.strftime("%m/%d/%Y")}"
    end
  end
end

def delete_event
  Event.all.each_with_index do |event, index|
    puts "\n#{index+1}) **#{event.description.capitalize}**"
    puts "At #{event.location}"
    if event.start.strftime("%m/%d/%Y") == event.end.strftime("%m/%d/%Y")
      puts "On #{event.start.strftime("%m/%d/%Y")} #{event.start.strftime(" from %I:%M%p")} #{event.end.strftime(" until %I:%M%p")}"
    else
      puts "On #{event.start.strftime("%m/%d/%Y")} #{event.start.strftime(" from %I:%M%p")} #{event.end.strftime(" until %I:%M%p")} ending #{event.end.strftime("%m/%d/%Y")}"
    end
  end
  puts "\nChoose by number which event would you like to delete or press 'm' to return to the main menu."
  input = gets.chomp
  if input == 'M' || input ==  'm'
    system "clear"
    main_menu
  else
    system "clear"
    event_to_destroy = Event.all[input.to_i-1].description
    puts "Are you sure you want to delete #{event_to_destroy}? 'y' or 'n'"
    yesno = gets.chomp.downcase
    if yesno == 'y'
    Event.all[input.to_i-1].destroy
    puts "#{event_to_destroy} has been destroyed!\n"
    elsif yesno == 'n'
      delete_event
    else
      puts "Invalid"
      main_menu
    end
  end
end


def edit_event
  Event.all.each_with_index do |event, index|
    puts "\n#{index+1}) **#{event.description.capitalize}**"
    puts "At #{event.location}"
    if event.start.strftime("%m/%d/%Y") == event.end.strftime("%m/%d/%Y")
      puts "On #{event.start.strftime("%m/%d/%Y")} #{event.start.strftime(" from %I:%M%p")} #{event.end.strftime(" until %I:%M%p")}"
    else
      puts "On #{event.start.strftime("%m/%d/%Y")} #{event.start.strftime(" from %I:%M%p")} #{event.end.strftime(" until %I:%M%p")} ending #{event.end.strftime("%m/%d/%Y")}"
    end
  end
  puts "Choose by number which event would you like to edit."
  input = gets.chomp.to_i
  event_to_edit = Event.all[input-1]
  puts "What part of this event would you like to edit?"
  puts "Press 'd' for description"
  puts "Press 'l' for location"
  puts "Press 's' for starting date & time"
  puts "Press 'e' for ending date & time"
  puts "Press 'm' to return to the main menu"
  choice = gets.chomp.downcase
  system "clear"
  case choice
  when 'd'
    puts "Enter the new description."
    new_description = gets.chomp.capitalize
    Event.all[input-1].edit_description(new_description)
    system "clear"
    puts "#{new_description} has been updated!"
  when 'l'
    puts "Enter the new location."
    new_location = gets.chomp
    Event.all[input-1].edit_location(new_location)
    system "clear"
    puts "#{new_location} has been updated!"
  when 's'
    puts "Enter the new starting date and time: YYYY-MM-DD 00:00 millitary time only please"
    new_startdatetime = gets.chomp
    Event.all[input-1].edit_startdatetime(new_startdatetime)
    system "clear"
    puts "#{new_startdatetime} has been updated!"
  when 'e'
    puts "Enter the new ending date and time: YYYY-MM-DD 00:00 millitary time only please"
    new_enddatetime = gets.chomp
    Event.all[input-1].edit_enddatetime(new_enddatetime)
    system "clear"
    puts "#{new_enddatetime} has been updated!"
  when 'm'
    main_menu
  else
    puts "Invalid input"
    edit_event
  end
end

main_menu
