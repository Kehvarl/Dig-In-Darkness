require 'app/game.rb'

# TODO
# - Hide "Passive" count
# - Increase "Defend" decay rate based on "Passive" Count
# - "Fortify" reduces "Passive" Count
# - Sleep/Whisper-spike to  setting a counter/value based on whisper level.  Use this counter to trigger nightmares



class MyGame < Game

    MEDIATE_MESSAGES = [
        {whisper_min: 0, whisper_max: 10, text: "Dear Diary: I meditated and I feel empowered."},
        {whisper_min: 0, whisper_max: 15, text: "Dear Diary: That was a very nice cup of tea."},
        {whisper_min: 5, whisper_max: 20, text: "Dear Diary: Napped a lot."},
        {whisper_min: 5, whisper_max: 25, text: "Hello Friend: Why don't you evern write back?"},
        {whisper_min: 10, whisper_max: 25, text: "Dear Diary: Did you know you can see shapes with your eyes closed?"},
        {whisper_min: 10, whisper_max: 30, text: "Dear Diary: Sometimes I don't want to stop meditating."},
        {whisper_min: 15, whisper_max: 35, text: "Dear meditating, I diaried and spilled my tea."},
        {whisper_min: 15, whisper_max: 40, text: "Lalalalalalallalalalala."},
        {whisper_min: 20, whisper_max: 45, text: "Words.  So many words.   What did they mean?"},
        {whisper_min: 20, whisper_max: 50, text: "Dear Diary: I meditated and I feel tired."},
        {whisper_min: 25, whisper_max: 55, text: ".derewopme leef I dna detatidem I :yraiD raeD"}
        ]

    INTRUSION_MESSAGES = [
        { whisper_min: 5,  text: "Why are you writing this?" },
        { whisper_min: 10, text: "We can see you." },
        { whisper_min: 15, text: "That wasn't meditation." },
        { whisper_min: 20, text: "Stop pretending this helps." },
        { whisper_min: 25, text: "The Management is disappointed.", color:{r:230, g:80, b:80}  },
        { whisper_min: 30, text: "You missed a spot." },
        { whisper_min: 35, text: "We're still here." },
        { whisper_min: 40, text: "You don't control this." },
        { whisper_min: 35, text: "SYSTEM NOTICE: Sanity levels unstable.", color:{r:230, g:80, b:230} },
        { whisper_min: 40, text: "You are not authorized to ignore this." },
        { whisper_min: 45, text: "Stop clicking.", color:{r:255, g:255, b:255}  },
        { whisper_min: 50, text: "The Diary is not private." }
        ]


    def initialize args
        super

        @location = :room

        create_button :save, 700, 500, "Save"
        @buttons[:save].location =  :room
        reveal_button :save

        create_button :load, 700, 500, "Load"
        @buttons[:load].location =  :hall
        reveal_button :load

        # Build Clarity, Clarity makes the world better
        create_button :meditate, 600, 400, "Meditation"
        @buttons[:meditate].location =  :room
        highlight_button :meditate
        auto_highlight :meditate, 100, 25
        reveal_button :meditate
        @block_whispers = 25 # Too low, but a start...

        # Keep this above 0 at all costs
        create_button :sanity, 600, 450, "Sanity"
        #@buttons[:sanity].location =  :room
        highlight_button :sanity, 100
        auto_highlight :sanity, 0, 10
        reveal_button :sanity
        @defend_increment = 0.05

        # You gotta sleep sometime...
        @focus_max = 50
        generate_resource(:focus, qty=@focus_max)
        create_button :sleep, 600, 500, "Sleep"
        @buttons[:sleep].location =  :room
        highlight_button :sleep

        # A way to bring down Whispers
        create_button :fortify, 600, 350, "Reaffirm Self (3)"
        @buttons[:fortify].location =  :room
        highlight_button :fortify
        create_unlock(:fortify)

        # Let's keep track of things
        create_log :diary, 300, 10, 680, 270

        # Things get... weird
        create_actor :whispers
        @actors[:whispers].ticks_total = 120

        # Somewehere to go
        create_button :door, 600, 300, "Door"
        @buttons[:door].location =  :room
        highlight_button :door
        reveal_button :door

        #-- Hallway
        # Look Around
        create_button :explore, 600, 400, "Explore"
        @buttons[:explore].location =  :hall
        highlight_button :explore
        reveal_button :explore

        # Somewehere to go
        create_button :return_room, 600, 300, "Return to Room"
        @buttons[:return_room].location =  :hall
        highlight_button :return_room
        reveal_button :return_room
    end

    def change_room room
        if @location == room
            return
        end

        @location = room
    end

    def volatility base=1
        base * (1.0 + (get_resource(:clarity) ** 2) * 0.002)
    end

    def door_clicked
        change_room :hall
    end

    def return_room_clicked
        change_room :room
    end

    def save_clicked
        save_game
    end

    def load_clicked
        load_game
    end

    def whispers_tick
        a = @actors[:whispers]
        a.ticks_remaining -=1
        if a.ticks_remaining <= 0
            generate_resource(:whispers, qty = volatility(1))
            a.ticks_remaining = a.ticks_total
            #(a.ticks_total + (get_resource(:clarity) * 7.2)).clamp(120, 480).to_i
            if rand(10) <3
                whispers = ["Whispers", "Ghostly touch", "Self doubt", "Management would like a word."]
                set_resource_label(:whispers, whispers.sample)
            end
            whisper_value = get_resource(:whispers)
            chance = volatility((whisper_value ** 1.3) * 0.002)
            chance = chance.clamp(0, 0.75)
            if rand < chance
                allowed = INTRUSION_MESSAGES.select { |m| whisper_value >= m[:whisper_min] }
                intrusion = allowed.sample

                if intrusion
                    c = intrusion.color || { r: 180, g: 80, b: 200 }
                    add_message(:diary, intrusion.text, c )
                end
            end
        end
    end

    def fortify_clicked
        b = @buttons[:fortify]
        if b.highlight_percent >= 100
            if use_resource(:clarity, 3)
                b.highlight_percent = 0
                use_resource(:whispers, 5)
            end
        end
    end

    def fortify_tick
        b = @buttons[:fortify]
        if get_resource(:clarity) >= 3
            if unlock(:fortify)
                add_message(:diary, "I found a technique that might be helpful.")
            end
            b.highlight_percent = 100
        else
            b.highlight_percent = 0
        end
    end

    def fortify_unlocked
        reveal_button :fortify
    end

    def get_meditate_message(value)
        allowed = MEDIATE_MESSAGES.select {|m| m.whisper_min <= value && m.whisper_max >= value }
        msg = allowed.sample()
        msg ? msg.text : "Dear Diary: ..."
    end

    def meditate_clicked
        b = @buttons[:meditate]
        if b.highlight_percent >= 100
            if use_resource(:focus, volatility(5))
                generate_resource(:clarity)
                b.highlight_percent = 0
                restart_highlight :meditate, 0, 100
                add_message(:diary, get_meditate_message(get_resource(:whispers)))
            else
                add_message(:diary, "I don't think I have it in me to meditate now.  I need some sleep.")
                reveal_button :sleep
            end
        end
    end

    def meditate_tick
        #b = @buttons[:meditate]
        #b.highlight_percent += 1
        # If I don't touch meditate, does it do anything?  Maybe if I leave it at 100% long enough.
    end

    def sleep_tick
        b = @buttons[:sleep]
        if not b.show and get_resource(:focus) < 5
            reveal_button :sleep
        end
        if get_resource(:focus) < @focus_max
            b.highlight_percent = 100
        end
    end

    def sleep_clicked
        b = @buttons[:sleep]
        if b.highlight_percent >= 100
            b.highlight_percent = 0
            set_resource(:focus, @focus_max)
            set_resource(:clarity, (get_resource(:clarity) - 3).to_i)
            # Spike Whispers.   TODO:  Replace with a nightmare counter, and gated spikes or other actions
            generate_resource(:whispers, 4)
        end
    end

    def sanity_clicked
        b = @buttons[:sanity]
        if b.highlight_percent > 0
            b.highlight_percent = 100
            restart_highlight :sanity, 100, 0
        end
    end

    def sanity_tick
        b = @buttons[:sanity]
        whispers = get_resource(:whispers)
        #b.highlight_percent -= @defend_increment + (whispers * 0.01) * (1.0 + get_resource(:clarity) * 0.02)
        if b.highlight_percent <= 0 and b.show
            if whispers < 10
                msg = "I don't feel like myself anymore."
            elsif whispers < 25
                msg = "I don't feel like myself."
            else
                msg = "I don't."
            end
            add_message(:diary, "Dear Diary: #{msg}")
            b.show = false
            @running = false
        end
    end
end
