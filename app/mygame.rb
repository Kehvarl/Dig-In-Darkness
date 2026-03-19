require 'app/game.rb'
require 'app/proc_gen.rb'

class MyGame < Game

    def initialize args
        super

        setup_globals
        setup_surface
        setup_entry

        @location = :surface
        @last_observation = nil
    end

# ============================================================
# No Location / Global
# Elements available in multiple scenes
# ============================================================
    def setup_globals
        create_log :notes, 300, 10, 680, 270
        set_resource :light, 100, show=false
        set_resource :darkness, 0, show=false
        set_resource :finds, 0, show=false
        set_resource :relics, 0, show=false
        @finds = []


        # Ascend, Observe, and Excavate available in several rooms
        create_button :ascend, 600, 300, "Ascend"
        @buttons[:ascend].location =  [:entry, :gallery]
        highlight_button :ascend, 100
        reveal_button :ascend

        create_button :observe, 600, 350, "Observe"
        @buttons[:observe].location =  [:entry, :gallery]
        highlight_button :observe
        reveal_button :observe

        create_button :excavate, 600, 400, "Excavate"
        @buttons[:excavate].location =  [:entry, :gallery]
        highlight_button :excavate
        reveal_button :excavate
    end

    # We will cheat and dispatch to a room-specific button based on the current room
    def observe_clicked
        if not button_highlight_full?(:observe)
            return
        end

        if get_resource(:light) < get_resource(:darkness)
            add_message(:notes, "You cannot see well enough to explore further.")
            set_highlight(:observe, 0)
            return
        end

        if self.respond_to?("#{@location}_observe".to_sym)
            self.send("#{@location}_observe".to_sym)
        end
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

        if self.respond_to?("#{@location}_excavate".to_sym)
            self.send("#{@location}_excavate".to_sym)
        end
    end

    # Ascend always returns to basecamp, no matter how deep you have delved.
    def ascend_clicked
        if get_resource(:light) < get_resource(:darkness)
            add_message(:notes, "You stumble your way back along the path.  It's a good thing you left a rope to follow.")
        end
        change_location :surface
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
            #generate_resource(:relics, 1)
            find = ProcGen.generate_find()
            messages = [
                "Carefully brushing away the dust reveals",
                "You clean the object and discover",
                "Beneath the dirt lies",
                "The artifact turns out to be"
            ]

            add_message(:notes, "#{messages.sample} #{ProcGen.describe_find(find)}")
            @finds << find

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
        create_actor :darkness, ticks_total=60, location=:entry

    end

    def entry_first_entered
        on_enter_entry("A cave entrance leading to a perfectly rectangular space; choked with debris.")
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

    def entry_observe
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

    def entry_excavate
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

# ============================================================
# :gallery
#
# A rich, treasure-filled chamber
#
# Available Actions:
# - Excavate
# - Observe
# - Ascend
# - (Enter Crypt)
# - (Enter Ritual Room)
#
# Actors:
# - Darkness (slow Light drain)
# - Structure (low frequency ambient events)
#
# Unlocks:
# - 3 Crypts.  Each unlocks after finding 4 inscriptions
# - Ritual Room.  Unlocks after 5 artwork.
#
# Tone:
# Cool air. Settling dust.
#
# Purpose:
# More excavation fun.
# ============================================================
    def setup_gallery
        create_unlock(:gallery_crypt1)
        create_unlock(:gallery_crypt2)
        create_unlock(:gallery_crypt3)
        create_unlock(:gallery_ritual_room)
    end

    def gallery_first_entered
        on_enter_gallery("A vast columnaded chamber rich in carvings, murals, and objects.")
        set_resource(:inscriptions, 0, show=false)
        set_resource(:artwork, 0, show=false)
    end

    def gallery_entered
        messages = [
            "Dust drifts through the lantern beam.",
            "The air is cool and still.",
            "Ancient stone blocks form a low archway.",
            "Your footsteps echo softly in the chamber."
        ]
        on_enter_gallery(messages.sample)
    end

    def on_enter_gallery message
        add_message(:notes, message)
        set_resource(:darkness, 5)
        set_highlight(:excavate, 0)
        set_highlight(:observe, 100)
    end

    def gallery_messages(phase=1, type=nil)
        m = [
            {phase: 1, type: :artwork, message: "Beneath the dust, shadows show a hint of carvings on the walls"},
            {phase: 1, type: :artwork, message: "A flash of color on a column gives a tantalizing clue to an ancient painting."},
            {phase: 1, type: :inscription, message: "A line of carved symbols hints at deeper meanings"},
            {phase: 1, type: :inscription, message: "Tiny pictograms outline the carving of a seated figure."},
            {phase: 1, type: :inscription, message: ""},
            {phase: 1, type: :find, message: "At the base of a column, dust cakes a strange shape."},
            {phase: 1, type: :find, message: "A niche could contain hidden treasures."},
            {phase: 1, type: :find, message: "As your lantern beam shines by, something glints in the shadows."},
            {phase: 1, type: :find, message: "Indentations hint at missing inlays."}
        ]

        out = m.select do |m|
            m[:phase] <= phase && (type == nil || m[:type] == type)
        end

        out
    end

    def gallery_phase
        r = get_resource(:inscriptions)
        if r < 4
            return 1  # No crypts
        elsif r < 8
            return 2  # First Crypt revealed
        elsif r < 12
            return 3  # Second crypt revealed
        elsif get_resource(:artwork) < 5
            return 4  # Third crypt revealed
        else
            return 5  # Ritual Room revealed
        end

    end

    def gallery_observe
        ph = gallery_phase
        r = rand
        if r < 0.5
            @last_observation = gallery_messages(ph, :find).sample()
        elsif r < 0.7
            @last_observation = gallery_messages(ph,:inscription).sample()
        elsif r < 0.8
            @last_observation = gallery_messages(ph, :artwork).sample()
        else
            @last_observation = nil
        end

        if @last_observation
            add_message(:notes, @last_observation.message)
        else
            add_message(:notes, "Nothing stands out… but that in itself feels strange.")

        end
        adjust_highlight(:excavate, 25)
    end

    def gallery_excavate
        messages = [
            "Your trowel clinks against something; you'll need to study this later",
            "Your questing fingers brush over something loose. It bears further study",
            "A small packet, worth opening with care",
            "Another trinket, why were so many left in the entryway?"
        ]

        if not @last_observation
            add_message(:notes, messages.sample)
            generate_resource(:finds)
        elsif @last_observation.type == :find
            add_message(:notes, messages.sample)
            generate_resource(:finds)
        elsif @last_observation.type == :inscription
            generate_resource(:inscriptions, 1)
            add_message(:notes, "You uncover a fragment of inscribed stone.")
        elsif @last_observation.type == :artwork
            generate_resource(:artwork, 1)
            add_message(:notes, "A section of mural emerges from the dust.")
        else
            puts "Error, invalid observation type"
        end

        set_highlight(:excavate, 0)
        set_highlight(:observe, 100)
        gallery_test_unlocks
    end

    def gallery_test_unlocks
        if get_resource(:inscriptions) >= 4
            unlock(:gallery_crypt1)
        end

        if get_resource(:inscriptions) >= 8
            unlock(:gallery_crypt2)
        end

        if get_resource(:inscriptions) >= 12
            unlock(:gallery_crypt3)
        end

        if get_resource(:artwork) >= 5
            unlock(:gallery_ritual_room)
        end
    end

    def gallery_crypt1_unlocked
        add_message(:notes, "<First Crypt Unlock>")
    end

    def gallery_crypt2_unlocked
        add_message(:notes, "<Second Crypt Unlock>")
    end

    def gallery_crypt3_unlocked
        add_message(:notes, "<Third Crypt Unlock>")
    end

    def gallery_ritual_room_unlocked
        add_message(:notes, "<Ritual Room Unlock>")
    end
end
