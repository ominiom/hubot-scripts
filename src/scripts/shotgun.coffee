# Description:
#   Call shotgun!
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_SHOTGUN_HARDCORE - Disables:
#     Seeing who has each position
#     Only being able to call the next position
#
# Commands:
#   hubot shotgun <place> - Make a call for that place (numbers only - e.g. 1st, 2nd...)
#   hubot shotgun next - Gives the next available place to call
#   hubot shotgun reload - Resets all calls made
#   hubot shotgun show - Shows all calls made so far
#
# Author:
#   ominiom

module.exports = (robot) ->
  robot.respond /shotgun\s+(\d+)/i, (msg) ->
    place = parseInt msg.match[1]
    user  = msg.message.user.name
    
    if shotgun.loaded(user)
      return msg.reply "You are already #{ordinalize shotgun.place(user)}"

    if shotgun.whois(place)
      return msg.reply "#{shotgun.whois place} is already #{ordinalize place}!"

    if not shotgun.hardcore and place isnt shotgun.next
      return msg.reply "Don't you mean #{shotgun.next_place()}?"

    if place is shotgun.next or shotgun.hardcore
      shotgun.load user, place
    
    if shotgun.loaded(user)
      msg.send "#{user} has called #{ordinalize(place)}"
  
  unless shotgun.hardcore
    robot.respond /shotgun next$/i, (msg) ->
      msg.reply "You'll want to call #{shotgun.next_place()}"

    robot.respond /shotgun (show|inspect)$/i, (msg) ->
      msg.send (if shotgun.loaded() then shotgun.inspect() else 'Shotgun is empty!')

  robot.respond /shotgun (reload|fire|empty|reset)$/i, (msg) ->
    msg.send shotgun.inspect()
    shotgun.reload()
    msg.send "Shotgun is now armed!"

ordinalize = (number) ->
  ordinal =
    if (number % 100) in [10..20]
      'th'
    else
      ['th', 'st', 'nd', 'rd'][number % 10] or 'th'

  "#{number}#{ordinal}"

class Shotgun
  constructor: ->
    @reload()

  reload: ->
    @magazine = {}
    @next = 1

  loaded: (user) ->
    if user
      user of @magazine
    else
      @magazine isnt {}

  place: (user) ->
    @magazine[user]

  whois: (n) ->
    return user if place is n for user, place of @magazine 

  load: (user, place) ->
    @magazine[user] = place
    @next++ if place >= @next

  inspect: ->
    places = (place for user, place of @magazine).sort()

    ("#{ordinalize(place)} - #{@whois(place) or 'No-one'}") for place in places

  next_place: ->
    ordinalize @next

shotgun = new Shotgun
shotgun.hardcore = process.env.HUBOT_SHOTGUN_HARDCORE