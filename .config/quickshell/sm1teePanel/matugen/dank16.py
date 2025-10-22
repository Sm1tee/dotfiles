#!/usr/bin/env python3
import colorsys
import sys

def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16)/255.0 for i in (0, 2, 4))

def rgb_to_hex(r, g, b):
    r = max(0, min(1, r))
    g = max(0, min(1, g)) 
    b = max(0, min(1, b))
    return f"#{int(r*255):02x}{int(g*255):02x}{int(b*255):02x}"

def luminance(hex_color):
    r, g, b = hex_to_rgb(hex_color)
    def srgb_to_linear(c):
        return c/12.92 if c <= 0.03928 else ((c + 0.055)/1.055) ** 2.4
    return 0.2126 * srgb_to_linear(r) + 0.7152 * srgb_to_linear(g) + 0.0722 * srgb_to_linear(b)

def contrast_ratio(hex_fg, hex_bg):
    lum_fg = luminance(hex_fg)
    lum_bg = luminance(hex_bg)
    lighter = max(lum_fg, lum_bg)
    darker = min(lum_fg, lum_bg)
    return (lighter + 0.05) / (darker + 0.05)

def ensure_contrast(hex_color, hex_bg, min_ratio=4.5, is_light_mode=False):
    current_ratio = contrast_ratio(hex_color, hex_bg)
    if current_ratio >= min_ratio:
        return hex_color
    
    r, g, b = hex_to_rgb(hex_color)
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    
    for step in range(1, 30):
        delta = step * 0.02
        
        if is_light_mode:
            new_v = max(0, v - delta)
            candidate = rgb_to_hex(*colorsys.hsv_to_rgb(h, s, new_v))
            if contrast_ratio(candidate, hex_bg) >= min_ratio:
                return candidate
                
            new_v = min(1, v + delta)
            candidate = rgb_to_hex(*colorsys.hsv_to_rgb(h, s, new_v))
            if contrast_ratio(candidate, hex_bg) >= min_ratio:
                return candidate
        else:
            new_v = min(1, v + delta)
            candidate = rgb_to_hex(*colorsys.hsv_to_rgb(h, s, new_v))
            if contrast_ratio(candidate, hex_bg) >= min_ratio:
                return candidate
                
            new_v = max(0, v - delta)
            candidate = rgb_to_hex(*colorsys.hsv_to_rgb(h, s, new_v))
            if contrast_ratio(candidate, hex_bg) >= min_ratio:
                return candidate
    
    return hex_color

def generate_palette(base_color, is_light=False, honor_primary=None, background=None):
    r, g, b = hex_to_rgb(base_color)
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    
    palette = []
    
    if background:
        bg_color = background
        palette.append(bg_color)
    elif is_light:
        bg_color = "#f8f8f8"
        palette.append(bg_color)
    else:
        bg_color = "#1a1a1a"
        palette.append(bg_color)
    
    red_h = 0.0
    if is_light:
        red_color = rgb_to_hex(*colorsys.hsv_to_rgb(red_h, 0.75, 0.85))
        palette.append(ensure_contrast(red_color, bg_color, 4.5, is_light))
    else:
        red_color = rgb_to_hex(*colorsys.hsv_to_rgb(red_h, 0.6, 0.8))
        palette.append(ensure_contrast(red_color, bg_color, 4.5, is_light))
    
    green_h = 0.33
    if is_light:
        green_color = rgb_to_hex(*colorsys.hsv_to_rgb(green_h, max(s * 0.9, 0.75), v * 0.6))
        palette.append(ensure_contrast(green_color, bg_color, 4.5, is_light))
    else:
        green_color = rgb_to_hex(*colorsys.hsv_to_rgb(green_h, max(s * 0.65, 0.5), v * 0.9))
        palette.append(ensure_contrast(green_color, bg_color, 4.5, is_light))
    
    yellow_h = 0.08
    if is_light:
        yellow_color = rgb_to_hex(*colorsys.hsv_to_rgb(yellow_h, max(s * 0.85, 0.7), v * 0.7))
        palette.append(ensure_contrast(yellow_color, bg_color, 4.5, is_light))
    else:
        yellow_color = rgb_to_hex(*colorsys.hsv_to_rgb(yellow_h, max(s * 0.5, 0.45), v * 1.4))
        palette.append(ensure_contrast(yellow_color, bg_color, 4.5, is_light))
    
    if is_light:
        blue_color = rgb_to_hex(*colorsys.hsv_to_rgb(h, max(s * 0.9, 0.7), v * 1.1))
        palette.append(ensure_contrast(blue_color, bg_color, 4.5, is_light))
    else:
        blue_color = rgb_to_hex(*colorsys.hsv_to_rgb(h, max(s * 0.8, 0.6), min(v * 1.6, 1.0)))
        palette.append(ensure_contrast(blue_color, bg_color, 4.5, is_light))
    
    mag_h = h - 0.03 if h >= 0.03 else h + 0.97
    if honor_primary:
        hr, hg, hb = hex_to_rgb(honor_primary)
        hh, hs, hv = colorsys.rgb_to_hsv(hr, hg, hb)
        if is_light:
            mag_color = rgb_to_hex(*colorsys.hsv_to_rgb(hh, max(hs * 0.9, 0.7), hv * 0.85))
            palette.append(ensure_contrast(mag_color, bg_color, 4.5, is_light))
        else:
            mag_color = rgb_to_hex(*colorsys.hsv_to_rgb(hh, hs * 0.8, hv * 0.75))
            palette.append(ensure_contrast(mag_color, bg_color, 4.5, is_light))
    elif is_light:
        mag_color = rgb_to_hex(*colorsys.hsv_to_rgb(mag_h, max(s * 0.75, 0.6), v * 0.9))
        palette.append(ensure_contrast(mag_color, bg_color, 4.5, is_light))
    else:
        mag_color = rgb_to_hex(*colorsys.hsv_to_rgb(mag_h, max(s * 0.7, 0.6), v * 0.85))
        palette.append(ensure_contrast(mag_color, bg_color, 4.5, is_light))
    
    cyan_h = h + 0.08
    if honor_primary:
        palette.append(ensure_contrast(honor_primary, bg_color, 4.5, is_light))
    elif is_light:
        cyan_color = rgb_to_hex(*colorsys.hsv_to_rgb(cyan_h, max(s * 0.8, 0.65), v * 1.05))
        palette.append(ensure_contrast(cyan_color, bg_color, 4.5, is_light))
    else:
        cyan_color = rgb_to_hex(*colorsys.hsv_to_rgb(cyan_h, max(s * 0.6, 0.5), min(v * 1.25, 0.85)))
        palette.append(ensure_contrast(cyan_color, bg_color, 4.5, is_light))
    
    if is_light:
        palette.append("#2e2e2e")
        palette.append("#4a4a4a")
    else:
        palette.append("#abb2bf")
        palette.append("#5c6370")
    
    if is_light:
        bright_red = rgb_to_hex(*colorsys.hsv_to_rgb(red_h, 0.6, 0.9))
        palette.append(ensure_contrast(bright_red, bg_color, 3.0, is_light))
        bright_green = rgb_to_hex(*colorsys.hsv_to_rgb(green_h, max(s * 0.8, 0.7), v * 0.65))
        palette.append(ensure_contrast(bright_green, bg_color, 3.0, is_light))
        bright_yellow = rgb_to_hex(*colorsys.hsv_to_rgb(yellow_h, max(s * 0.75, 0.65), v * 0.75))
        palette.append(ensure_contrast(bright_yellow, bg_color, 3.0, is_light))
        if honor_primary:
            hr, hg, hb = hex_to_rgb(honor_primary)
            hh, hs, hv = colorsys.rgb_to_hsv(hr, hg, hb)
            bright_blue = rgb_to_hex(*colorsys.hsv_to_rgb(hh, min(hs * 1.1, 1.0), min(hv * 1.2, 1.0)))
            palette.append(ensure_contrast(bright_blue, bg_color, 3.0, is_light))
        else:
            bright_blue = rgb_to_hex(*colorsys.hsv_to_rgb(h, max(s * 0.8, 0.7), min(v * 1.3, 1.0)))
            palette.append(ensure_contrast(bright_blue, bg_color, 3.0, is_light))
        bright_mag = rgb_to_hex(*colorsys.hsv_to_rgb(mag_h, max(s * 0.9, 0.75), min(v * 1.25, 1.0)))
        palette.append(ensure_contrast(bright_mag, bg_color, 3.0, is_light))
        bright_cyan = rgb_to_hex(*colorsys.hsv_to_rgb(cyan_h, max(s * 0.75, 0.65), min(v * 1.25, 1.0)))
        palette.append(ensure_contrast(bright_cyan, bg_color, 3.0, is_light))
    else:
        bright_red = rgb_to_hex(*colorsys.hsv_to_rgb(red_h, 0.45, min(1.0, 0.9)))
        palette.append(ensure_contrast(bright_red, bg_color, 3.0, is_light))
        bright_green = rgb_to_hex(*colorsys.hsv_to_rgb(green_h, max(s * 0.5, 0.4), min(v * 1.5, 0.9)))
        palette.append(ensure_contrast(bright_green, bg_color, 3.0, is_light))
        bright_yellow = rgb_to_hex(*colorsys.hsv_to_rgb(yellow_h, max(s * 0.4, 0.35), min(v * 1.6, 0.95)))
        palette.append(ensure_contrast(bright_yellow, bg_color, 3.0, is_light))
        if honor_primary:
            hr, hg, hb = hex_to_rgb(honor_primary)
            hh, hs, hv = colorsys.rgb_to_hsv(hr, hg, hb)
            bright_blue = rgb_to_hex(*colorsys.hsv_to_rgb(hh, min(hs * 1.2, 1.0), min(hv * 1.1, 1.0)))
            palette.append(ensure_contrast(bright_blue, bg_color, 3.0, is_light))
        else:
            bright_blue = rgb_to_hex(*colorsys.hsv_to_rgb(h, max(s * 0.6, 0.5), min(v * 1.5, 0.9)))
            palette.append(ensure_contrast(bright_blue, bg_color, 3.0, is_light))
        bright_mag = rgb_to_hex(*colorsys.hsv_to_rgb(mag_h, max(s * 0.7, 0.6), min(v * 1.3, 0.9)))
        palette.append(ensure_contrast(bright_mag, bg_color, 3.0, is_light))
        bright_cyan = rgb_to_hex(*colorsys.hsv_to_rgb(h + 0.02 if h + 0.02 <= 1.0 else h + 0.02 - 1.0, max(s * 0.6, 0.5), min(v * 1.2, 0.85)))
        palette.append(ensure_contrast(bright_cyan, bg_color, 3.0, is_light))
    
    if is_light:
        palette.append("#1a1a1a")
    else:
        palette.append("#ffffff")
    
    return palette

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: dank16.py <hex_color> [--light] [--kitty] [--honor-primary HEX] [--background HEX]", file=sys.stderr)
        sys.exit(1)
    
    base = sys.argv[1]
    if not base.startswith('#'):
        base = '#' + base
    
    is_light = "--light" in sys.argv
    is_kitty = "--kitty" in sys.argv
    
    honor_primary = None
    if "--honor-primary" in sys.argv:
        try:
            honor_idx = sys.argv.index("--honor-primary")
            if honor_idx + 1 < len(sys.argv):
                honor_primary = sys.argv[honor_idx + 1]
                if not honor_primary.startswith('#'):
                    honor_primary = '#' + honor_primary
        except (ValueError, IndexError):
            print("Error: --honor-primary requires a hex color", file=sys.stderr)
            sys.exit(1)
    
    background = None
    if "--background" in sys.argv:
        try:
            bg_idx = sys.argv.index("--background")
            if bg_idx + 1 < len(sys.argv):
                background = sys.argv[bg_idx + 1]
                if not background.startswith('#'):
                    background = '#' + background
        except (ValueError, IndexError):
            print("Error: --background requires a hex color", file=sys.stderr)
            sys.exit(1)
    
    colors = generate_palette(base, is_light, honor_primary, background)
    
    if is_kitty:
        # Kitty color format mapping
        kitty_colors = [
            ("color0", colors[0]),
            ("color1", colors[1]),
            ("color2", colors[2]),
            ("color3", colors[3]),
            ("color4", colors[4]),
            ("color5", colors[5]),
            ("color6", colors[6]),
            ("color7", colors[7]),
            ("color8", colors[8]),
            ("color9", colors[9]),
            ("color10", colors[10]),
            ("color11", colors[11]),
            ("color12", colors[12]),
            ("color13", colors[13]),
            ("color14", colors[14]),
            ("color15", colors[15])
        ]
        
        for name, color in kitty_colors:
            print(f"{name}   {color}")
    else:
        for i, color in enumerate(colors):
            print(f"palette = {i}={color}")