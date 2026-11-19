import os
import math
from PIL import Image, ImageDraw, ImageFilter

def create_fitness_icon(size=1024):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    
    # 1. Background gradient: Midnight Slate (#0F172A) to Crimson Ember (#991B1B -> #EA580C)
    bg = Image.new("RGBA", (size, size))
    draw_bg = ImageDraw.Draw(bg)
    
    c_top = (15, 23, 42)      # Deep Slate #0F172A
    c_mid = (127, 29, 29)     # Deep Crimson #7F1D1D
    c_bot = (234, 88, 12)     # Energetic Orange #EA580C
    
    for y in range(size):
        ratio = y / float(size)
        if ratio < 0.45:
            f = ratio / 0.45
            r = int(c_top[0] + f * (c_mid[0] - c_top[0]))
            g = int(c_top[1] + f * (c_mid[1] - c_top[1]))
            b = int(c_top[2] + f * (c_mid[2] - c_top[2]))
        else:
            f = (ratio - 0.45) / 0.55
            r = int(c_mid[0] + f * (c_bot[0] - c_mid[0]))
            g = int(c_mid[1] + f * (c_bot[1] - c_mid[1]))
            b = int(c_mid[2] + f * (c_bot[2] - c_mid[2]))
        draw_bg.line([(0, y), (size, y)], fill=(r, g, b, 255))
    
    # 2. Add warm energy radial glow
    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse([size * 0.2, size * 0.15, size * 0.8, size * 0.75], fill=(251, 146, 60, 60))
    glow_draw.ellipse([size * 0.35, size * 0.3, size * 0.65, size * 0.6], fill=(254, 215, 170, 70))
    glow = glow.filter(ImageFilter.GaussianBlur(radius=50))
    bg = Image.alpha_composite(bg, glow)
    
    # 3. Geometric Muscular Barbell & Power Emblem
    overlay = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    
    # Outer hex or power ring
    center = (size // 2, size // 2)
    radius = int(size * 0.38)
    
    # Glowing power circles behind barbell
    draw.ellipse([center[0] - radius, center[1] - radius, center[0] + radius, center[1] + radius],
                 outline=(255, 255, 255, 40), width=6)
    draw.ellipse([center[0] - radius + 30, center[1] - radius + 30, center[0] + radius - 30, center[1] + radius - 30],
                 outline=(251, 146, 60, 100), width=4)
                 
    # Barbell Bar (angled or horizontal, bold horizontal barbell)
    bar_y = center[1]
    bar_left = 170
    bar_right = size - 170
    bar_height = 36
    draw.rounded_rectangle([bar_left, bar_y - bar_height//2, bar_right, bar_y + bar_height//2],
                           radius=12, fill=(241, 245, 249, 255), outline=(203, 213, 225, 255), width=3)
                           
    # Barbell Plates (Left side)
    # Inner collar
    draw.rounded_rectangle([bar_left + 80, bar_y - 70, bar_left + 110, bar_y + 70], radius=8, fill=(148, 163, 184, 255))
    # Big bumper plate 1
    draw.rounded_rectangle([bar_left + 115, bar_y - 190, bar_left + 165, bar_y + 190], radius=16, fill=(234, 88, 12, 255), outline=(255, 255, 255, 220), width=5)
    # Big bumper plate 2
    draw.rounded_rectangle([bar_left + 175, bar_y - 160, bar_left + 215, bar_y + 160], radius=14, fill=(239, 68, 68, 255), outline=(255, 255, 255, 200), width=4)
    # Smaller plate 3
    draw.rounded_rectangle([bar_left + 225, bar_y - 120, bar_left + 255, bar_y + 120], radius=10, fill=(251, 191, 36, 255))

    # Barbell Plates (Right side)
    # Inner collar
    draw.rounded_rectangle([bar_right - 110, bar_y - 70, bar_right - 80, bar_y + 70], radius=8, fill=(148, 163, 184, 255))
    # Big bumper plate 1
    draw.rounded_rectangle([bar_right - 165, bar_y - 190, bar_right - 115, bar_y + 190], radius=16, fill=(234, 88, 12, 255), outline=(255, 255, 255, 220), width=5)
    # Big bumper plate 2
    draw.rounded_rectangle([bar_right - 215, bar_y - 160, bar_right - 175, bar_y + 160], radius=14, fill=(239, 68, 68, 255), outline=(255, 255, 255, 200), width=4)
    # Smaller plate 3
    draw.rounded_rectangle([bar_right - 255, bar_y - 120, bar_right - 225, bar_y + 120], radius=10, fill=(251, 191, 36, 255))
    
    # Center emblem: Bold Power Crest / Flame Triangle
    crest_pts = [
        (center[0], center[1] - 110),
        (center[0] + 90, center[1] + 60),
        (center[0], center[1] + 110),
        (center[0] - 90, center[1] + 60),
    ]
    draw.polygon(crest_pts, fill=(15, 23, 42, 230), outline=(254, 215, 170, 255), width=6)
    
    # Lightning / Power Slash inside crest
    bolt_pts = [
        (center[0] + 12, center[1] - 80),
        (center[0] - 28, center[1] - 5),
        (center[0] + 6, center[1] - 5),
        (center[0] - 14, center[1] + 80),
        (center[0] + 28, center[1] + 5),
        (center[0] - 6, center[1] + 5),
    ]
    draw.polygon(bolt_pts, fill=(251, 146, 60, 255), outline=(255, 255, 255, 255), width=2)
    
    img = Image.alpha_composite(bg, overlay)
    
    # Rounded squircle mask
    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, size, size], radius=224, fill=255)
    
    final_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    final_img.paste(img, (0, 0), mask)
    final_draw = ImageDraw.Draw(final_img)
    final_draw.rounded_rectangle([2, 2, size - 2, size - 2], radius=224, outline=(255, 255, 255, 50), width=4)
    
    return final_img

def main():
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    assets_icon_dir = os.path.join(base_dir, "assets", "icon")
    os.makedirs(assets_icon_dir, exist_ok=True)
    
    print("Generating 1024x1024 Master Fitness Icon...")
    master = create_fitness_icon(1024)
    master_path = os.path.join(assets_icon_dir, "app_icon.png")
    master.save(master_path, "PNG")
    print(f"Master icon saved to {master_path}")
    
    sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    
    for folder, dim in sizes.items():
        out_dir = os.path.join(assets_icon_dir, folder)
        os.makedirs(out_dir, exist_ok=True)
        resized = master.resize((dim, dim), Image.Resampling.LANCZOS)
        out_path = os.path.join(out_dir, "ic_launcher.png")
        resized.save(out_path, "PNG")
        print(f"Generated {out_path} ({dim}x{dim})")

    print("App icon generation complete!")

if __name__ == "__main__":
    main()
