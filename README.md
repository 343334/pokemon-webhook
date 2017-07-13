# pokemon-webhook

Built in ruby this is a webhook setup to work with either RocketMap or Monocle as an alternative or supplement to PokeAlarm

Requirements:  Docker, Ruby

Features: 
  1. Can notify to Twitter, GroupMe and Slack
  2. Has ability to limit posting to set time left on notification
  3. Uses cloud.io for caching static images for less google api calls
  4. GroupMe - supports !cmds for changing notifications per channel
  5. Slack - supports highlighted keyword notifications
  6. Supports Geofencing and reverse geocode lookups
  
  
Todo list:
  
  1. tidy up this README with installation and config options
  2. Build a wiki to help assist
  3. edit lib/encounters.rb to support global config vars for google api and cloud io tokens
  4. Verify if config/fences dir is necessary or if all fences can be stored in config.json
  5. Move all global variables to config - trash pokemon, twitter queue amount/time left amount - also make global for all services if not
  6. Code in ability to accept gym/raid notifications
  7. Create variables ie: useGroupMe False/True and halt if config options arent set for service, or dont halt if not set and False
  
  
Installation: 
  
  1. Install Docker
  2. git clone https://github.com/343334/pokemon-webhook/pokemon-webhook.git
  3. copy config/config.json/template to config/config.json and edit
  4. edit config/environment
  5. currently edit lib/encounters.rb with google api token and cloud io token can search for ## in the code for any places that need configuration beyond config dir
  6. cd pokemon-webhook && docker build -t pokemon-webhook .
  7. run ./start.sh
  8. point your webhooks to http://localhost:8000/webhook/notify/sourcename   where sourcename matches a source in config.json
  9. make sure port 4567 is not in use as thats currently hardcoded in as bind port, also default binds to 0.0.0.0
  10. if you dont want to use all groupme, twitter and slack, edit line 21 in server.rb on which services you want enabled.
  11. For slack - make sure to /invite botname to each channel you have defined.
  
  
Pull Requests:
  Feel free and submit any for review to help improve this project. Thanks
  
  
Extra Notes:
  This was not design for public use hence why there is many missing error checks for configuration options but would love
  to make it more user friendly for everyone.
