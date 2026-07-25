import os
from PIL import Image

SRC = r'D:\work\mindora\assets\Seima_Icon.png'
BASE = r'D:\work\mindora'

BG_COLOR = (61, 90, 128)  # #3D5A80

img = Image.open(SRC).convert('RGBA')
w, h = img.size

bbox = img.getbbox()
if bbox:
    raw_content = img.crop(bbox)
else:
    raw_content = img
cw, ch = raw_content.size

def compute_visual_center(im):
    """Alpha-weighted center of mass for visual centering."""
    pixels = im.load()
    iw, ih = im.size
    total = 0
    sx = sy = 0.0
    for y in range(ih):
        for x in range(iw):
            a = pixels[x, y][3]
            total += a
            sx += x * a
            sy += y * a
    if total == 0:
        return (iw / 2.0, ih / 2.0)
    return (sx / total, sy / total)

# Visual center in original image coords
vis_cx, vis_cy = compute_visual_center(img)
# Geometric center of content bbox in original image coords
geo_cx = bbox[0] + cw / 2.0
geo_cy = bbox[1] + ch / 2.0
# Correction: how much visual center differs from geometric center
corr_x = vis_cx - geo_cx
corr_y = vis_cy - geo_cy
# Map correction to content-space (0..1 relative to content dimensions)
corr_nx = corr_x / cw if cw else 0
corr_ny = corr_y / ch if ch else 0

print(f'Content bbox: {bbox}  ({cw}x{ch})')
print(f'Geometric center: ({geo_cx:.1f}, {geo_cy:.1f})')
print(f'Visual center: ({vis_cx:.1f}, {vis_cy:.1f})')
print(f'Correction offset: ({corr_x:.1f}, {corr_y:.1f})')
print(f'Correction normalized: ({corr_nx:.3f}, {corr_ny:.3f})')

def resize_visually(target_size, pad_ratio, content=None):
    """Resize content to fit centered in target_size with visual centering."""
    c = content if content else raw_content
    ccw, cch = c.size
    out = Image.new('RGBA', (target_size, target_size), (0, 0, 0, 0))
    max_dim = target_size * (1.0 - pad_ratio * 2)
    scale = min(max_dim / ccw, max_dim / cch) if ccw and cch else 1
    new_w = max(1, int(ccw * scale))
    new_h = max(1, int(cch * scale))
    resized = c.resize((new_w, new_h), Image.LANCZOS)
    # Apply visual centering correction
    dx = int(corr_nx * new_w)
    dy = int(corr_ny * new_h)
    x = (target_size - new_w) // 2 + dx
    y = (target_size - new_h) // 2 + dy
    out.paste(resized, (x, y), resized)
    return out

def resize_centered(target_size, pad_ratio=0.0, content=None):
    """Legacy geometric centering for non-icon surfaces (iOS, web, etc.)."""
    c = content if content else raw_content
    ccw, cch = c.size
    out = Image.new('RGBA', (target_size, target_size), (0, 0, 0, 0))
    max_dim = target_size * (1.0 - pad_ratio * 2)
    scale = min(max_dim / ccw, max_dim / cch) if ccw and cch else 1
    new_w = max(1, int(ccw * scale))
    new_h = max(1, int(cch * scale))
    resized = c.resize((new_w, new_h), Image.LANCZOS)
    x = (target_size - new_w) // 2
    y = (target_size - new_h) // 2
    out.paste(resized, (x, y), resized)
    return out

def save_png(path, pil_img):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    pil_img.save(path, 'PNG')


# ─── Android mipmap ─────────────────────────────────────
ANDROID_LAUNCHER = {
    'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192,
}
ANDROID_ADAPTIVE = {
    'mdpi': 108, 'hdpi': 162, 'xhdpi': 216, 'xxhdpi': 324, 'xxxhdpi': 432,
}

mipmap_base = os.path.join(BASE, 'android', 'app', 'src', 'main', 'res')

# Adaptive foreground: 22% padding for Samsung safe-zone (circular/squircle mask)
for density, size in ANDROID_ADAPTIVE.items():
    fore = resize_visually(size, pad_ratio=0.22)
    save_png(os.path.join(mipmap_base, f'mipmap-{density}', 'ic_adaptive_fore.png'), fore)

# Adaptive background (vector drawable handles this, but keep PNG fallback)
for density, size in ANDROID_ADAPTIVE.items():
    bg = Image.new('RGBA', (size, size), BG_COLOR + (255,))
    save_png(os.path.join(mipmap_base, f'mipmap-{density}', 'ic_adaptive_bg.png'), bg)

# Fallback ic_launcher.png (pre-API-26): colored bg + icon
for density, size in ANDROID_LAUNCHER.items():
    fallback = Image.new('RGBA', (size, size), BG_COLOR + (255,))
    icon = resize_visually(size, pad_ratio=0.08)
    fallback.paste(icon, (0, 0), icon)
    save_png(os.path.join(mipmap_base, f'mipmap-{density}', 'ic_launcher.png'), fallback)

# Splash icon: uses ANDROID_ADAPTIVE sizes (108dp base) for crisp splash rendering.
# 25% padding ensures logo fits within ~72dp circular safe zone.
for density, size in ANDROID_ADAPTIVE.items():
    icon = resize_visually(size, pad_ratio=0.25)
    save_png(os.path.join(mipmap_base, f'mipmap-{density}', 'splash_icon.png'), icon)

print('Android mipmap icons regenerated (adaptive sizes for splash).')

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
    if size >= 1024:
        save_png(os.path.join(ios_dir, fname), img)
    else:
        icon = resize_visually(size, pad_ratio=0.10)
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
    icon = img if size >= 1024 else resize_visually(size, pad_ratio=0.10)
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
    icon = resize_visually(size, pad_ratio=0.10)
    if 'favicon' in fname:
        icon = resize_visually(size, pad_ratio=0.05)
        save_png(os.path.join(web_dir, fname), icon)
    else:
        bg.paste(icon, (0, 0), icon)
        save_png(os.path.join(web_dir, fname), bg)
root_icon = Image.open(os.path.join(web_dir, 'favicon.png')).convert('RGBA') if os.path.exists(os.path.join(web_dir, 'favicon.png')) else resize_visually(64, pad_ratio=0.05)
save_png(os.path.join(BASE, 'web', 'favicon.png'), root_icon)
print('Web icons regenerated.')

# ─── Windows ICO ─────────────────────────────────────────
win_ico_sizes = [16, 24, 32, 48, 64, 96, 128, 256]
ico_images = []
for size in win_ico_sizes:
    bg = Image.new('RGBA', (size, size), BG_COLOR + (255,))
    icon = resize_visually(size, pad_ratio=0.08)
    bg.paste(icon, (0, 0), icon)
    ico_images.append(bg)
win_ico_path = os.path.join(BASE, 'windows', 'runner', 'resources', 'app_icon.ico')
ico_images[0].save(win_ico_path, format='ICO', sizes=[(s, s) for s in win_ico_sizes])
print('Windows ICO regenerated.')

print('Done. All icons regenerated from Seima_Icon.png with visual centering.')
