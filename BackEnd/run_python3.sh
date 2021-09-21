python3 -m venv venv
source venv/bin/activate
pip install -r requirement.in
python manage.py makemigrations
python manage.py migrate
python3 manage.py runserver
