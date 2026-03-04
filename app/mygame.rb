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
    end

    def restock_tick
        a = @actors[:restock]
        a.ticks_remaining -=1
        if a.ticks_remaining <= 0
            a.ticks_remaining = a.ticks_total
            if get_resource(:darkness) > 0
                use_resource(:darkness, 5)
            end
        end
    end

    def descend_tick
        @buttons[:descend].highlight_percent = 100-(get_resource :darkness)
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
    end

    def entry_entered
        add_message(:notes, "<Short description, maybe from a small collection>")
    end

    def darkness_tick
        a = @actors[:darkness]
        a.ticks_remaining -=1
        if a.ticks_remaining <= 0
            a.ticks_remaining = a.ticks_total
            if get_resource(:darkness) < 100
                generate_resource(:darkness, 10)
            end
        end
    end

    def ascend_clicked
        change_location :surface
    end


end
