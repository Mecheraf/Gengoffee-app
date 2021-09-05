# Generated by Django 3.2.2 on 2021-08-24 11:40

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('Auth', '0029_merge_0027_auto_20210529_1748_0028_auto_20210611_0921'),
    ]

    operations = [
        migrations.AddField(
            model_name='account',
            name='role',
            field=models.CharField(choices=[('ADM', 'Admin'), ('MOD', 'Modérateur'), ('MEM', 'Membre')], default='MEM', max_length=3),
        ),
    ]