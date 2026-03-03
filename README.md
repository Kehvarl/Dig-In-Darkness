# Button Experiments
Taking some ideas from [DRGTK Sample "Save-Load-Game"](https://docs.dragonruby.org/#/samples/save-load?id=save-load-game-mainrb)

Specifically:
- we will identify our buttons with a label, and also our on-click routines with a related label.
- on-click will exist outside of the button itself
- Simplify the buttons by converting them from classes to hashes

### Definitions

An Action changes game state
May require Resources to Trigger
When Triggered:
  May consume Resources
  May create Resources
  May create Agents
  May change Agents
  May create Buttons
  May change Buttons

A Button triggers an Action when Clicked

An Agent triggers an Action on a Schedule

Simpler Button definitions:
A button may be a list of hashes with
- a .solid! for the button background
- a .solid! for the button progress fill
- a .border! for the button border
- a .label! for the button text
- params with
  - generates:  Map of key:value pairs for the button's output.  eg: {loot:1, other:1}
  - unlocks_after: What conditions must be met to unlock? eg: {loot:100, ship:1}
  - costs: what it costs to click the button.
  - on_click:   Symbol to call when clicking the button.
    This must match a function name that we can call using "send"
