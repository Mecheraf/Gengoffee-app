# Generated by Django 3.2.2 on 2021-05-13 13:57

import Auth.validators
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('Auth', '0020_alter_account_age'),
    ]

    operations = [
        migrations.AlterField(
            model_name='account',
            name='age',
            field=models.IntegerField(default=1, validators=[Auth.validators.validate_age]),
            preserve_default=False,
        ),
    ]