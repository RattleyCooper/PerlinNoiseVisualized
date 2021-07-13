import perlin  # https://github.com/Nycto/PerlinNim
import random, math
import chroma, vmath, pixie  # https://github.com/treeform

randomize()


# Tile enum for storing colors of different "elevations"
type 
    Tile = enum
        AbyssWater = (0, "#133253"),
        Water = (1, "#2B4C6F"),
        Surf = (2, "#4A6B8A"),
        WetSand = (3, "#806C15"),
        Sand = (4, "#AA9539"),
        FertileGrass = (5, "#2C4E00"),
        Grass = (6, "#4A7413"),
        DryGrass = (7, "#98C261"),
        DarkStone = (8, "#303030"),
        Stone = (9, "#474747"),
        LightStone = (10, "#595959"),
        Snow = (11, "#e6e6e6"),
        Null = (12, "#000000")


proc choose_tile(elevation: float64): Tile =
    # Choos a tile based on the elevation given from noise function
    if elevation < 0.45:
        return Tile.AbyssWater
    if elevation < 0.51:
        return Tile.Water
    if elevation < 0.53:
        return Tile.Surf
    if elevation < 0.5355:
        return Tile.WetSand
    if elevation < 0.55:
        return Tile.Sand
    if elevation < 0.56:
        return Tile.FertileGrass
    if elevation < 0.58:
        return Tile.Grass
    if elevation < 0.60:
        return Tile.DryGrass
    if elevation < 0.62:
        return Tile.DarkStone
    if elevation < 0.65:
        return Tile.Stone
    return Tile.Snow


proc build_image(image_size: Vec2, octaves: int, persistance: float64, image_scale: float64): Image =
    var noise = newNoise(1, octaves, persistance)
    let image = newImage(image_size.x.toInt, image_size.y.toInt)
    image.fill(rgba(0, 0, 0, 255))  # Fill base image with black

    for x in countup(1, image_size.x.toInt):
        for y in countup(1, image_size.y.toInt):
            # Adjust location to center the features of the noise
            # in the image frame.
            let location = vec2(x.toFloat, y.toFloat + 455.0)
            # Apply our own custom scaling
            let elevation = noise.pure_perlin(location.x * image_scale, location.y * image_scale)
            
            # Get tile enum based on location
            let tile = choose_tile(elevation)
            
            # Get color from the Tile enum
            let col = parseHtmlHex($tile)
            # Set pixel of image to color.
            image[x, y] = col

    return image


if isMainModule:
    var font = readFont("Roboto-Medium.ttf")
    font.size = 64
    var image_scale = 0.0015  # Closer to 0 scales larger.
    let img_size = vec2(1024.0, 1024.0)
    for octave in 0..12:
        for persist in 1..20:
            var p = round(persist.toFloat * 0.05, 2)
            var fname = "octaves - " & $octave & " - persistence - " & $persist & ".png"
            var text = "octaves: " & $octave & " persistence: " & $p
            echo text
            var i = build_image(img_size, octave, p, image_scale)
            i.fillText(font.typeset(text, bounds = vec2(1024, 1024 - 1024/4)), vec2(1024/8, 1024 - 1024/8))
            i.writeFile(fname)
