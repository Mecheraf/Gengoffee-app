from django.db import models

from Auth.models import Account


class Category(models.Model):
    name = models.CharField(max_length=100, null=False, unique=True)

class Event(models.Model):
    name = models.CharField(max_length=100, null=False)
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    date = models.DateTimeField(null=False)
    location = models.CharField(max_length=255, null=False)
    price = models.FloatField(null=False)
    description = models.TextField(null=False)

class Tag(models.Model):
    name = models.CharField(max_length=100, null=False)
    event = models.ForeignKey(Event, on_delete=models.CASCADE)

    def __str__(self):
        return self.name

class UserJoined(models.Model):
    event = models.ForeignKey(Event, on_delete=models.CASCADE)
    user = models.ForeignKey(Account, on_delete=models.CASCADE)