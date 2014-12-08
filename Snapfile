# Uncommend the lines below you want to change by removing the # in the beginning

# A list of devices you want to take the screenshots from
devices([
  "iPhone 6",
  "iPhone 6 Plus",
  "iPhone 5",
  "iPhone 4s",
  "iPad Air"
])

languages([
  'en-US',
])

# Where should the resulting screenshots be stored?
screenshots_path "./screenshots"

# JavaScript UIAutomation file
# js_file './snapshot.js'

# The name of the project's scheme
scheme 'Barback'

# Where is your project (or workspace)? Provide the full path here
# project_path './YourProject.xcworkspace'

# By default, the latest version should be used automatically. If you want to change it, do it here
# ios_version '8.1'

# The path, on which the HTML file should be exported to
# html_path './screenshots.html'


# Custom Callbacks

# setup_for_device_change do |device| 
#   puts "Preparing device: #{device}"
# end

# setup_for_language_change do |lang, device|
#   puts "Running #{lang} on #{device}"
#   system("./popuplateDatabase.sh")
# end

# teardown_language do |lang, device|
#   puts "Finished with #{lang} on #{device}"
# end

teardown_device do |device|
   puts "Cleaning device #{device}"
   system("./cleanup.sh")
end
