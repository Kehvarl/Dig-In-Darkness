
def generate_find
    conditions = [
        "cracked",
        "weathered",
        "polished",
        "dust-covered",
        "chipped",
        "remarkably well preserved"
    ]

    materials = [
        "jade",
        "bronze",
        "gold",
        "clay",
        "obsidian",
        "bone"
    ]

    types = [
        "ring",
        "brooch",
        "figurine",
        "coin",
        "idol",
        "amulet"
    ]

    details = [
        "depicting a coiled serpent",
        "engraved with tiny runes",
        "bearing the mark of unknown meaning",
        "decorated with spiral motifs",
        "showing a stylized sun",
        "carved into the shape of a watchful eye"
    ]

    {
        condition: conditions.sample,
        material: materials.sample,
        type: types.sample,
        detail: details.sample,
        studied: false
    }
end

def describe_find(find)
    "A #{find[:condition]} #{find[:material]} #{find[:type]} #{find[:detail]}."
end
