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
        set_resource :finds, 0, show=false
        set_resource :relics, 0, show=false
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
        if get_resource(:finds) > 0
            @buttons[:findings].highlight_percent = 100
        end
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
        if @buttons[:findings].highlight_percent < 100
            return
        end

        if get_resource(:finds) > 0
            use_resource(:finds, 1)
            generate_resource(:relics, 1)

            messages = [
                "Carefully brushing away the dust reveals a carved idol.",
                "You clean the object and discover an etched bronze charm.",
                "Beneath the dirt lies a small clay tablet.",
                "The artifact turns out to be a delicate ceremonial ring."
            ]

            add_message(:notes, messages.sample)

            # Might need to track what relics we found if we ever need to reference them again
            # Perhaps there's use for procedurally generated relics.

        else
            add_message(:notes, "You have nothing new to study.")
            @buttons[:findings].highlight_percent = 0
        end
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
        on_enter_entry("<Detailed Description>")
    end

    def entry_entered
        messages = [
            "Dust drifts through the lantern beam.",
            "The air is cool and still.",
            "Ancient stone blocks form a low archway.",
            "Your footsteps echo softly in the chamber."
        ]
        on_enter_entry(messages.sample)
    end

    def on_enter_entry message
        add_message(:notes, message)
        set_resource(:darkness, 5)
        set_highlight(:excavate, 0)
        set_highlight(:observe, 100)
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
        if not button_highlight_full?(:observe)
            return
        end

        if get_resource(:light) < get_resource(:darkness)
            add_message(:notes, "You cannot see well enough to explore further.")
            set_highlight(:observe, 0)
            return
        end

        messages = [
            "The entry hallway is covered in worn and faded carvings.",
            "There is a feature that might be a doorway leading deeper", #Might need to tie this to an unlock
            "Weathered warnings dance beneath the light of your lantern",
            "The passage echoes with long forgotten whispers, and footsteps."
        ]
        if rand < 0.6
            add_message(:notes, messages.sample)
        end

        adjust_highlight(:excavate, 25)
    end

    def excavate_clicked
        if not button_highlight_full?(:excavate)
            return
        end
        if get_resource(:light) < get_resource(:darkness)
            add_message(:notes, "It is too dark to dig safely.")
            set_highlight(:excavate, 0)
            return
        end

        messages = [
            "Your trowel clinks against something; you'll need to study this later",
            "Your questing fingers brush over something loose. It bears further study",
            "A small packet, worth opening with care",
            "Another trinket, why were so many left in the entryway?"
        ]
        add_message(:notes, messages.sample)
        generate_resource(:finds)
        set_highlight(:excavate, 0)
        set_highlight(:observe, 100)
    end

    def ascend_clicked
        if get_resource(:light) < get_resource(:darkness)
            add_message(:notes, "You stumble your way back along the path.  It's a good thing you left a rope to follow.")
        end
        change_location :surface
    end


end
