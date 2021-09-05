# Generated by Django 3.2.2 on 2021-05-13 13:24

import Auth.validators
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('Auth', '0014_alter_account_avatar'),
    ]

    operations = [
        migrations.AddField(
            model_name='account',
            name='age',
            field=models.IntegerField(default=18, validators=[Auth.validators.validate_age]),
        ),
        migrations.AddField(
            model_name='account',
            name='city',
            field=models.CharField(default='', max_length=25),
        ),
        migrations.AddField(
            model_name='account',
            name='country',
            field=models.CharField(default='', max_length=25),
        ),
        migrations.AddField(
            model_name='account',
            name='first_name',
            field=models.CharField(default='', max_length=50),
        ),
        migrations.AddField(
            model_name='account',
            name='last_name',
            field=models.CharField(default='', max_length=50),
        ),
        migrations.AddField(
            model_name='account',
            name='show_age',
            field=models.BooleanField(default=True),
        ),
        migrations.AddField(
            model_name='account',
            name='show_city',
            field=models.BooleanField(default=True),
        ),
        migrations.AddField(
            model_name='account',
            name='show_country',
            field=models.BooleanField(default=True),
        ),
        migrations.AddField(
            model_name='account',
            name='show_first_name',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='account',
            name='show_last_name',
            field=models.BooleanField(default=False),
        ),
    ]