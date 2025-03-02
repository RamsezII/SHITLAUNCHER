from PIL import Image, ImageDraw

# Charger l'image
image_path = "icon.jpg"
ico_path_square = "icon_square.ico"
ico_path_round = "icon_round.ico"

img = Image.open(image_path).convert("RGBA")

# Sauvegarder l'icône carrée
img.save(ico_path_square, format="ICO", sizes=[(256, 256), (128, 128), (64, 64), (32, 32), (16, 16)])

# Créer un masque pour rendre l'image ronde
mask = Image.new("L", img.size, 0)
draw = ImageDraw.Draw(mask)
draw.ellipse((0, 0) + img.size, fill=255)

# Appliquer le masque à l'image
img.putalpha(mask)

# Sauvegarder l'icône ronde
img.save(ico_path_round, format="ICO", sizes=[(256, 256), (128, 128), (64, 64), (32, 32), (16, 16)])

print(f"✅ Icône carrée créée : {ico_path_square}")
print(f"✅ Icône ronde créée : {ico_path_round}")
