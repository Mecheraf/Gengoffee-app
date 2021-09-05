# Generated by Django 3.2.2 on 2021-05-13 14:09

import Auth.validators
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('Auth', '0022_auto_20210513_1401'),
    ]

    operations = [
        migrations.AlterField(
            model_name='account',
            name='gender',
            field=models.IntegerField(max_length=10, validators=[Auth.validators.validate_gender]),
        ),
    ]