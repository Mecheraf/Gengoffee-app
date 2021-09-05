# Generated by Django 3.2.2 on 2021-05-11 13:20

import Auth.models
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('Auth', '0004_alter_account_avatar'),
    ]

    operations = [
        migrations.AlterField(
            model_name='account',
            name='avatar',
            field=models.ImageField(default='/media/Avatar/default.png', upload_to=Auth.models.get_avatar_path),
        ),
    ]
