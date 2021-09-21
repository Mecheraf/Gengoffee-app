# Generated by Django 3.2.2 on 2021-09-21 13:40

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('Auth', '0032_alter_account_nationality'),
    ]

    operations = [
        migrations.AlterField(
            model_name='account',
            name='nationality',
            field=models.CharField(choices=[('FRE', 'Français'), ('JAP', 'Japonais'), ('OTHER', 'Other')], max_length=5),
        ),
    ]