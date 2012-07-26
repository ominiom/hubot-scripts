# Description:
#   Call shotgun!
#
# Dependencies:
#   None
#
# Configuration:
#   None
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
      return msg.send "You are already #{ordinalize shotgun.place(user)}"

    if place is shotgun.next()
      shotgun.load user
      msg.send "#{user} has called #{ordinalize(place)}"
    else
      msg.send "Don't you mean #{shotgun.next_place()}?"
  
  robot.respond /shotgun next$/i, (msg) ->
    msg.send "You'll want to call #{shotgun.next_place()}"

  robot.respond /shotgun (reload|fire|empty|reset)$/i, (msg) ->
    msg.send shotgun.inspect()
    shotgun.reload()
    msg.send "Shotgun is now armed!"

  robot.respond /shotgun (show|inspect)$/i, (msg) ->
    msg.send (if shotgun.loaded() then shotgun.inspect() else 'Shotgun is empty!')

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
    @magazine = [] 

  loaded: (user) ->
    if user
      user in @magazine
    else
      @magazine.length isnt 0

  place: (user) ->
    1 + @magazine.indexOf user

  load: (user) ->
    @magazine.push user

  next: ->
    @magazine.length + 1

  inspect: ->
    ("#{ordinalize(place + 1)} - #{user}") for user, place in @magazine

  next_place: ->
    ordinalize @next()

shotgun = new Shotgun