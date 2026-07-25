import os
from PIL import Image

SRC = r'D:\work\mindora\assets\Seima_Icon.png'
BASE = r'D:\work\mindora'

BG_COLOR = (61, 90, 128)  # #3D5A80

img = Image.open(SRC).convert('RGBA')
w, h = img.size

# Find actual content bbox (trim transparency)
bbox = img.getbbox()
if bbox:
    content = img.crop(bbox)
else:
    content = img
cw, ch = content.size

def resize_centered(target_size, pad_ratio=0.0):
    """Resize content to fit centered in target_size with optional padding ratio."""
    out = Image.new('RGBA', (target_size, target_size), (0, 0, 0, 0))
    max_dim = target_size * (1.0 - pad_ratio * 2)
    scale = min(max_dim / cw, max_dim / ch)
    new_w = int(cw * scale)
    new_h = int(ch * scale)
    resized = content.resize((new_w, new_h), Image.LANCZOS)
    x = (target_size - new_w) // 2
    y = (target_size - new_h) // 2
    out.paste(resized, (x, y), resized)
    return out

def save_png(path, pil_img):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    pil_img.save(path, 'PNG')

# ─── Android mipmap ─────────────────────────────────────
# Launcher icon sizes (density -> px)
ANDROID_LAUNCHER = {
    'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192,
}
# Adaptive foreground sizes (108dp * density)
ANDROID_ADAPTIVE = {
    'mdpi': 108, 'hdpi': 162, 'xhdpi': 216, 'xxhdpi': 324, 'xxxhdpi': 432,
}

mipmap_base = os.path.join(BASE, 'android', 'app', 'src', 'main', 'res')

# Generate adaptive foreground (transparent bg, center with ~12% padding for safe zone)
for density, size in ANDROID_ADAPTIVE.items():
    fore = resize_centered(size, pad_ratio=0.12)
    save_png(os.path.join(mipmap_base, f'mipmap-{density}', 'ic_adaptive_fore.png'), fore)

# Generate adaptive background (full color fill - we use XML drawable, but keep a PNG fallback)
for density, size in ANDROID_ADAPTIVE.items():
    bg = Image.new('RGBA', (size, size), BG_COLOR + (255,))
    save_png(os.path.join(mipmap_base, f'mipmap-{density}', 'ic_adaptive_bg.png'), bg)

# Generate fallback ic_launcher.png (icon on colored bg, centered, at launcher sizes)
for density, size in ANDROID_LAUNCHER.items():
    fallback = Image.new('RGBA', (size, size), BG_COLOR + (255,))
    icon = resize_centered(size, pad_ratio=0.08)
    fallback.paste(icon, (0, 0), icon)
    save_png(os.path.join(mipmap_base, f'mipmap-{density}', 'ic_launcher.png'), fallback)

# Generate splash_icon.png (icon only, transparent bg, centered at mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi)
for density, size in ANDROID_LAUNCHER.items():
    icon = resize_centered(size, pad_ratio=0.05)
    save_png(os.path.join(mipmap_base, f'mipmap-{density}', 'splash_icon.png'), icon)

print('Android mipmap icons regenerated.')

# ─── iOS AppIcon ─────────────────────────────────────────
IOS_SIZES = {
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
}
ios_dir = os.path.join(BASE, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
for fname, size in IOS_SIZES.items():
    # iOS icons are opaque square with rounded corners applied by the system
    # Use the full Seima_Icon.png directly for 1024, and centered crop for others
    if size >= 1024:
        img.save(os.path.join(ios_dir, fname), 'PNG')
    else:
        icon = resize_centered(size, pad_ratio=0.10)
        save_png(os.path.join(ios_dir, fname), icon)
print('iOS AppIcon regenerated.')

# ─── macOS AppIcon ───────────────────────────────────────
MAC_SIZES = {
    'app_icon_16.png': 16,
    'app_icon_32.png': 32,
    'app_icon_64.png': 64,
    'app_icon_128.png': 128,
    'app_icon_256.png': 256,
    'app_icon_512.png': 512,
    'app_icon_1024.png': 1024,
}
mac_dir = os.path.join(BASE, 'macos', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
for fname, size in MAC_SIZES.items():
    icon = img if size >= 1024 else resize_centered(size, pad_ratio=0.10)
    save_png(os.path.join(mac_dir, fname), icon)
print('macOS AppIcon regenerated.')

# ─── Web icons ───────────────────────────────────────────
WEB_SIZES = {
    'Icon-192.png': 192,
    'Icon-512.png': 512,
    'Icon-maskable-192.png': 192,
    'Icon-maskable-512.png': 512,
    'favicon.png': 64,
}
web_dir = os.path.join(BASE, 'web', 'icons')
os.makedirs(web_dir, exist_ok=True)
for fname, size in WEB_SIZES.items():
    bg = Image.new('RGBA', (size, size), BG_COLOR + (255,))
    if 'maskable' in fname:
        icon = resize_centered(size, pad_ratio=0.10)
    else:
        icon = resize_centered(size, pad_ratio=0.10)
    if 'favicon' in fname:
        icon = resize_centered(size, pad_ratio=0.05)
        save_png(os.path.join(web_dir, fname), icon)
    else:
        bg.paste(icon, (0, 0), icon)
        save_png(os.path.join(web_dir, fname), bg)
# Also copy favicon to web root
root_icon = Image.open(os.path.join(web_dir, 'favicon.png')).convert('RGBA') if os.path.exists(os.path.join(web_dir, 'favicon.png')) else resize_centered(64, pad_ratio=0.05)
save_png(os.path.join(BASE, 'web', 'favicon.png'), root_icon)
print('Web icons regenerated.')

# ─── Windows ICO ─────────────────────────────────────────
# Windows app_icon.ico - we need to create an ICO with multiple sizes
# Use PNG-encoded ICO (supported by modern Windows)
win_ico_sizes = [16, 24, 32, 48, 64, 96, 128, 256]
ico_images = []
for size in win_ico_sizes:
    bg = Image.new('RGBA', (size, size), BG_COLOR + (255,))
    icon = resize_centered(size, pad_ratio=0.08)
    bg.paste(icon, (0, 0), icon)
    ico_images.append(bg)
win_ico_path = os.path.join(BASE, 'windows', 'runner', 'resources', 'app_icon.ico')
ico_images[0].save(win_ico_path, format='ICO', sizes=[(s, s) for s in win_ico_sizes])
print('Windows ICO regenerated.')

# ─── iOS legacy launch images ────────────────────────────
# These are deprecated but let's keep them consistent
launch_dir = os.path.join(BASE, 'ios', 'Runner', 'Assets.xcassets', 'LaunchImage.imageset')
for f in ['LaunchImage.png', 'LaunchImage@2x.png', 'LaunchImage@3x.png']:
    p = os.path.join(launch_dir, f)
    if os.path.exists(p):
        print(f'Preserved legacy: {f}')
print('Done. All icons regenerated from Seima_Icon.png.')
