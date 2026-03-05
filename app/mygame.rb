require 'app/game.rb'

class MyGame < Game

    def initialize args
        super

        setup_globals
        setup_surface
        setup_entry

        @location = :surface
    end

# ============================================================
# No Location / Global
# Elements available in all scenes
# ============================================================
    def setup_globals
        create_log :notes, 300, 10, 680, 270
        set_resource :light, 100, show=false
        set_resource :darkness, 0, show=false
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

        create_button :descend, 600, 300, "Descend"
        @buttons[:descend].location =  :surface
        highlight_button :descend, 100
        reveal_button :descend

        create_button :supplies, 600, 350, "Prepare Supplies"
        @buttons[:supplies].location =  :surface
        highlight_button :supplies
        reveal_button :supplies

        create_button :findings, 600, 400, "Study Findings"
        @buttons[:findings].location =  :surface
        highlight_button :findings
        reveal_button :findings

        create_actor :restock, ticks_total=60, location=:surface
    end

    def surface_entered
        add_message(:notes, "You've returned to your basecamp on the surface to recharge your lantern and review your finds.")
    end

    def restock_tick
        a = @actors[:restock]
        a.ticks_remaining -=1
        if a.ticks_remaining <= 0
            a.ticks_remaining = a.ticks_total
            if get_resource(:light) < 100
                generate_resource(:light, 5)
            end
        end
    end

    def supplies_clicked
    end

    def findings_clicked
    end

    def descend_tick
        @buttons[:descend].highlight_percent = (get_resource :light)
    end

    def descend_clicked
        if @buttons[:descend].highlight_percent >= 100
            @buttons[:descend].highlight_percent = 0
            change_location :entry
        end
    end

# ============================================================
# :entry
#
# First underground chamber.
#
# Available Actions:
# - Excavate
# - Observe
# - Ascend
#
# Actors:
# - Darkness (slow Light drain)
# - Structure (low frequency ambient events)
#
# Tone:
# Cool air. Settling dust.
#
# Purpose:
# Introduce excavation loop.
# ============================================================
    def setup_entry

        create_button :ascend, 600, 300, "Ascend"
        @buttons[:ascend].location =  :entry
        highlight_button :ascend, 100
        reveal_button :ascend

        create_button :observe, 600, 350, "Observe"
        @buttons[:observe].location =  :entry
        highlight_button :observe
        reveal_button :observe

        create_button :excavate, 600, 400, "Excavate"
        @buttons[:excavate].location =  :entry
        highlight_button :excavate
        reveal_button :excavate

        create_actor :darkness, ticks_total=60, location=:entry
        #@actors[:darkness].location = :entry

    end

    def entry_first_entered
        add_message(:notes, "<Describe entrance hall in detail>")
        set_resource(:darkness, 5)
    end

    def entry_entered
        add_message(:notes, "<Short description, maybe from a small collection>")
        set_resource(:darkness, 5)
    end

    def darkness_tick
        darkness = @actors[:darkness]
        darkness.ticks_remaining -=1
        if darkness.ticks_remaining <= 0
            darkness.ticks_remaining = darkness.ticks_total
            if use_resource(:light, get_resource(:darkness))
                #If we've used up the last of our usable light, tell us.
                if get_resource(:light) < get_resource(:darkness)
                    add_message(:notes, "Your lantern sputters. Darkness presses in from every direction.")
                end
            else
                if use_resource(:light, 1)
                    add_message(:notes, "You fiddle with the lantern and coax a faint glow, it's getting harder to see the path back")
                else
                    add_message(:notes, "Nothing you try works, it's too dark to see.")
                end
            end
        end
    end

    def observe_clicked
    end

    def excavate_clicked
        if get_resource(:light) < get_resource(:darkness)
            add_message(:notes, "It is too dark to dig safely.")
            return
        end
        #Dig, message and some sort of pickups. So we'll need an inventory system eventually.
    end

    def ascend_clicked
        if get_resource(:light) < get_resource(:darkness)
            add_message(:notes, "You stumble your way back along the path.  It's a good thing you left a rope to follow.")
        end
        change_location :surface
    end


end
