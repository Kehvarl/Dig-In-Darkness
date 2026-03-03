require 'app/game.rb'

class MyGame < Game

    def initialize args
        super

        setup_surface
        setup_entry

        @location = :surface
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
        highlight_button :descend, 100
        reveal_button :descend

        create_button :supplies, 600, 250, "Prepare Supplies"
        @buttons[:supplies].location =  :surface
        highlight_button :supplies
        reveal_button :supplies

        create_button :findings, 600, 300, "Study Findings"
        @buttons[:findings].location =  :surface
        highlight_button :findings
        reveal_button :findings
    end

    def descend_tick
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

        create_button :ascend, 600, 200, "Ascend"
        @buttons[:ascend].location =  :entry
        highlight_button :ascend, 100
        reveal_button :ascend

        create_button :observe, 600, 250, "Observe"
        @buttons[:observe].location =  :entry
        highlight_button :observe
        reveal_button :observe

        create_button :excavate, 600, 300, "Excavate"
        @buttons[:excavate].location =  :entry
        highlight_button :excavate
        reveal_button :excavate

        create_actor :darkness
        @actors[:darkness].location = :entry

    end

    def darkness_tick
    end

    def ascend_clicked
        change_location :surface
    end


end
