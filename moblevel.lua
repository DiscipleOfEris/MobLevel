_addon.name = 'Mob Level'
_addon.author = 'DiscipleOfEris'
_addon.version = '1.1.0'
_addon.command = 'level'

-- Stores the level of mobs from widescan, and then displays the level of your current target.

require('tables')
packets = require('packets')
texts = require('texts')
require('coroutine')
config = require('config')

PACKET_WIDESCAN = 0x0F4
SPAWN_TYPE_ENEMY = 16

level = texts.new('${level}', {
    pos = {
        x = -18,
    },
    bg = {
        visible = false,
    },
    flags = {
        right = true,
        bottom = true,
        bold = true,
        draggable = false,
        italic = true,
    },
    text = {
        size = 10,
        alpha = 185,
        red = 255,
        green = 255,
        blue = 255,
    },
})

target_idx_to_level = T{}
scanning = false
co = nil

defaults = {}
defaults.auto = true
defaults.interval = 300
defaults.bg = { visible=false }
defaults.text = { size=10, alpha=185 }
defaults.ranks = {}
defaults.ranks.tooweak = { text={red=160, blue=160, green=160} }
defaults.ranks.easyprey = { text={red=40, blue=240, green=128} }
defaults.ranks.decentchallenge = { text={red=128, blue=128, green=255} }
defaults.ranks.evenmatch = { text={red=255, blue=255, green=255} }
defaults.ranks.tough = { text={red=240, blue=240, green=128} }
defaults.ranks.verytough = { text={red=240, blue=160, green=80} }
defaults.ranks.incrediblytough = { text={red=255, blue=80, green=80} }

settings = config.load(defaults)

windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)
  if id == PACKET_WIDESCAN then
    scanning = false
    packet = packets.parse('incoming', original)
    target_idx_to_level[packet.Index] = {lvl=packet.Level, expires=os.time()+settings.interval}
  end
end)

windower.register_event('prerender', function()
  local target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')
  
  if target == nil or target.spawn_type ~= SPAWN_TYPE_ENEMY then
    level:hide()
    return
  end
  
  if not target_idx_to_level:containskey(target.index) then
    if settings.auto then scan() end
    level:hide()
    return
  end
  
  t = target_idx_to_level[target.index]
  if t.lvl <= 0 or os.time() >= t.expires then
    if settings.auto then scan() end
    level:hide()
    return
  end
    
  local party_info = windower.ffxi.get_party_info()

  -- Adjust position for party member count
  level:pos_y(-76 - 20 * party_info.party1_count)
  
  local player = windower.ffxi.get_player()
  
  apply_settings(level, getSettingsByLevel(t.lvl, player.main_job_level), settings)
  level:update({level=t.lvl})
  level:show()
end)

windower.register_event('addon command', function(command, ...)
  args = L{...}
  if command == 'ws' or command == 'scan' then
    scan()
  elseif command == 'auto' or command == 'autoscan' then
    settings.auto = not settings.auto
    config.save(settings)
    
    if not settings.auto then
      if co~= nil then
        coroutine.close(co)
        co = nil
      end
    else
      scan()
      co = coroutine.schedule(routine, settings.interval)
    end
  elseif command == 'interval' then
    settings.interval = tonumber(args[1])
    config.save(settings)
  end
end)

function routine()
  scan()
  
  if settings.auto then
    co = coroutine.schedule(routine, settings.interval)
  end
end

function scan()
  if scanning then return end
  
  scanning = true
  packet = packets.new('outgoing', PACKET_WIDESCAN, {
    ['Flags'] = 1,
    ['_unknown1'] = 0,
    ['_unknown2'] = 0,
  })
  packets.inject(packet)
end

function getSettingsByLevel(mobLevel, playerLevel)
  diff = mobLevel - playerLevel
  if diff == 0 then return settings.ranks.evenmatch end

  if     playerLevel >= 71 then
    if      diff >= 8   then return settings.ranks.ranks.incrediblytough
    elseif  diff >= 4   then return settings.ranks.verytough
    elseif  diff >= 1   then return settings.ranks.tough
    elseif  diff >= -7  then return settings.ranks.decentchallenge
    elseif  diff >= -19 then return settings.ranks.easyprey end
  elseif playerLevel >= 66 then
    if      diff >= 8   then return settings.ranks.incrediblytough
    elseif  diff >= 4   then return settings.ranks.verytough
    elseif  diff >= 1   then return settings.ranks.tough
    elseif  diff >= -6  then return settings.ranks.decentchallenge
    elseif  diff >= -18 then return settings.ranks.easyprey end
  elseif playerLevel >= 61 then
    if      diff >= 8   then return settings.ranks.incrediblytough
    elseif  diff >= 4   then return settings.ranks.verytough
    elseif  diff >= 1   then return settings.ranks.tough
    elseif  diff >= -6  then return settings.ranks.decentchallenge
    elseif  diff >= -17 then return settings.ranks.easyprey end
  elseif playerLevel >= 56 then
    if      diff >= 8   then return settings.ranks.incrediblytough
    elseif  diff >= 4   then return settings.ranks.verytough
    elseif  diff >= 1   then return settings.ranks.tough
    elseif  diff >= -5  then return settings.ranks.decentchallenge
    elseif  diff >= -16 then return settings.ranks.easyprey end
  elseif playerLevel >= 51 then
    if      diff >= 7   then return settings.ranks.incrediblytough
    elseif  diff >= 4   then return settings.ranks.verytough
    elseif  diff >= 1   then return settings.ranks.tough
    elseif  diff >= -5  then return settings.ranks.decentchallenge
    elseif  diff >= -15 then return settings.ranks.easyprey end
  elseif playerLevel >= 46 then
    if      diff >= 6   then return settings.ranks.incrediblytough
    elseif  diff >= 4   then return settings.ranks.verytough
    elseif  diff >= 1   then return settings.ranks.tough
    elseif  diff >= -4  then return settings.ranks.decentchallenge
    elseif  diff >= -14 then return settings.ranks.easyprey end
  elseif playerLevel >= 41 then
    if      diff >= 5   then return settings.ranks.incrediblytough
    elseif  diff >= 4   then return settings.ranks.verytough
    elseif  diff >= 1   then return settings.ranks.tough
    elseif  diff >= -4  then return settings.ranks.decentchallenge
    elseif  diff >= -13 then return settings.ranks.easyprey end
  elseif playerLevel >= 36 then
    if      diff >= 5   then return settings.ranks.incrediblytough
    elseif  diff >= 4   then return settings.ranks.verytough
    elseif  diff >= 1   then return settings.ranks.tough
    elseif  diff >= -3  then return settings.ranks.decentchallenge
    elseif  diff >= -12 then return settings.ranks.easyprey end
  elseif playerLevel >= 31 then
    if      diff >= 5   then return settings.ranks.incrediblytough
    elseif  diff >= 4   then return settings.ranks.verytough
    elseif  diff >= 1   then return settings.ranks.tough
    elseif  diff >= -3  then return settings.ranks.decentchallenge
    elseif  diff >= -11 then return settings.ranks.easyprey end
  elseif playerLevel >= 21 then
    if      diff >= 6   then return settings.ranks.incrediblytough
    elseif  diff >= 5   then return settings.ranks.verytough
    elseif  diff >= 1   then return settings.ranks.tough
    elseif  diff >= -2  then return settings.ranks.decentchallenge
    elseif  diff >= -10 then return settings.ranks.easyprey end
  elseif playerLevel >= 11 then
    if      diff >= 6   then return settings.ranks.incrediblytough
    elseif  diff >= 5   then return settings.ranks.verytough
    elseif  diff >= 1   then return settings.ranks.tough
    elseif  diff >= -2  then return settings.ranks.decentchallenge
    elseif  diff >= -9  then return settings.ranks.easyprey end
  elseif playerLevel >= 6 then
    if      diff >= 6   then return settings.ranks.incrediblytough
    elseif  diff >= 5   then return settings.ranks.verytough
    elseif  diff >= 1   then return settings.ranks.tough
    elseif  diff >= -2  then return settings.ranks.decentchallenge
    elseif  diff >= -8  then return settings.ranks.easyprey end
  else --playerLevel >= 1
    if      diff >= 6   then return settings.ranks.incrediblytough
    elseif  diff >= 5   then return settings.ranks.verytough
    elseif  diff >= 1   then return settings.ranks.tough
    elseif  diff >= -2  then return settings.ranks.decentchallenge
    elseif  diff >= -7  then return settings.ranks.easyprey end
  end
  
  return settings.ranks.tooweak
end


function apply_settings(box, settings, default)
    bg = settings.bg and settings.bg.red and settings.bg or default.bg
    bg_alpha = settings.bg and settings.bg.alpha and settings.bg.alpha or default.bg.alpha
    text = settings.text and settings.text.red and settings.text or default.text
    text_alpha = settings.text and settings.text.alpha and settings.text.alpha or default.text.alpha
    
    box:bg_alpha(bg_alpha)
    box:bg_color(bg.red, bg.green, bg.blue)
    box:color(text.red, text.green, text.blue)
    box:alpha(text_alpha)
end