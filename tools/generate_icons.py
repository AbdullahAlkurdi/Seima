from PIL import Image
import os

SOURCE = 'assets/Mindora_Icon.png'
OUT = 'assets/app_icon'

img = Image.open(SOURCE).convert('RGBA')
os.makedirs(OUT, exist_ok=True)

def resize(size, path, bg=None):
    r = img.resize((size, size), Image.LANCZOS)
    if bg:
        c = Image.new('RGBA', (size, size), bg)
        c.paste(r, (0, 0), r)
        c.convert('RGB').save(path)
    else:
        r.save(path)

# Android mipmap
android = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}
for density, size in android.items():
    d = f'{OUT}/android-{density}'
    os.makedirs(d, exist_ok=True)
    resize(size, f'{d}/ic_launcher.png')
    resize(size, f'{d}/ic_launcher_round.png')
    # adaptive icon foreground (slightly smaller for safe zone, ~72% of area)
    fore_size = int(size * 0.62)
    r = img.resize((fore_size, fore_size), Image.LANCZOS)
    c = Image.new('RGBA', (size, size), (0,0,0,0))
    c.paste(r, ((size-fore_size)//2, (size-fore_size)//2), r)
    c.save(f'{d}/ic_adaptive_fore.png')

# Android adaptive background (seed color)
os.makedirs(f'{OUT}/android-anydpi', exist_ok=True)
bg_any = Image.new('RGB', (108, 108), (61, 90, 128))
bg_any.save(f'{OUT}/android-anydpi/ic_adaptive_bg.png')
for density, size in android.items():
    bg = Image.new('RGB', (size, size), (61, 90, 128))
    bg.save(f'{OUT}/android-{density}/ic_adaptive_bg.png')

# iOS
ios_sizes = {
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
ios_dir = f'{OUT}/ios'
os.makedirs(ios_dir, exist_ok=True)
for name, size in ios_sizes.items():
    resize(size, f'{ios_dir}/{name}')

# macOS
mac_sizes = {
    'app_icon_16.png': 16,
    'app_icon_32.png': 32,
    'app_icon_64.png': 64,
    'app_icon_128.png': 128,
    'app_icon_256.png': 256,
    'app_icon_512.png': 512,
    'app_icon_1024.png': 1024,
}
mac_dir = f'{OUT}/macos'
os.makedirs(mac_dir, exist_ok=True)
for name, size in mac_sizes.items():
    resize(size, f'{mac_dir}/{name}')

# Windows .ico (multi-resource)
ico_sizes = [16, 24, 32, 48, 64, 96, 128, 256]
ico_path = f'{OUT}/app_icon.ico'
# PIL can save ICO with multiple sizes
ico_imgs = []
for s in ico_sizes:
    r = img.resize((s, s), Image.LANCZOS)
    c = Image.new('RGBA', (s, s), (0,0,0,0))
    c.paste(r, (0, 0), r)
    ico_imgs.append(c)
ico_imgs[0].save(ico_path, format='ICO', sizes=[(s, s) for s in ico_sizes], append_images=ico_imgs[1:])

# Splash icon (large)
resize(512, f'{OUT}/splash_icon.png')

print('All icons generated.')
