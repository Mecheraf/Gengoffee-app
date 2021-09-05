# Groupe de zhang_e 863761

# Setup python project
Installer Postrgres vérifier que la commande 'pg_config' fonctionne

Dans le directory de Django :

python -m venv venv
ou 
python3 -m venv venv

Activer l'environement avec : 
source venv/bin/activate

puis :
pip install -r requirement.in

Crée une fichier .env en vous basant sur le .env.template

# Setup database
Créer la base de donnée

Faites :
python manage.py makemigrations
et
python manage.py migrate


Pour finir :
python3 manage.py runserver
