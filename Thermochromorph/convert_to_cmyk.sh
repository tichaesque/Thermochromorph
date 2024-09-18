rm data/img1/*.png
rm data/img2/*.png

source venv/bin/activate
python3 convert_image.py
deactivate