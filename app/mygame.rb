require 'app/game.rb'

# TODO
# - Hide "Passive" count
# - Increase "Defend" decay rate based on "Passive" Count
# - "Fortify" reduces "Passive" Count
# - Sleep/Whisper-spike to  setting a counter/value based on whisper level.  Use this counter to trigger nightmares



class MyGame < Game


    def initialize args
        super

        setup_surface

        @location = :surface
    end

    def change_location new_location
        if @location == new_location
            return
        end

        @location = new_location
        # Set a flag for a newly changed location
        # How to make this usable without checking and clearing it on every button, actor, etc
        # Maybe override Game.tick
        # If we pull buttons out of tick and into their own button_tick, we can override _that_ and respond to all buttons in the new location.
        # Or "newly-entered" can exist at the engine level, not the new game.
        # Also, first-time-in-location could be useful from a narrative sense.
    end

# ============================================================
# :surface
# Description: Open air above the buried structure.
#
# Available Actions:
# - Descend
# - Prepare Supplies (restore Light)
# - Study Findings
# ============================================================
    def setup_surface

        create_button :descend, 600, 200, "Descend"
        @buttons[:descend].location =  :surface
        highlight_button :descend
        reveal_button :descend

        create_button :supplies, 600, 200, "Prepare Supplies"
        @buttons[:supplies].location =  :surface
        highlight_button :supplies
        reveal_button :supplies

        create_button :findings, 600, 200, "Study Findings"
        @buttons[:findings].location =  :surface
        highlight_button :findings
        reveal_button :findings
    end


