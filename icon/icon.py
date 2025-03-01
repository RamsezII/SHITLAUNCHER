from PIL import Image

# Charger l'image
image_path = "icon.jpg"
ico_path = "icon.ico"

img = Image.open(image_path)

# Redimensionner pour Windows (taille 256x256, 128x128, etc.)
img.save(ico_path, format="ICO", sizes=[(256, 256), (128, 128), (64, 64), (32, 32), (16, 16)])

print(f"✅ Icône créée : {ico_path}")
