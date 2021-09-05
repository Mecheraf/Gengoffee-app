from rest_framework import serializers

from Auth.serializers import UserMinSerializer
from BackEnd.serializers import SearchBaseSerializer
from Event.models import Event, Tag, Category, UserJoined

class EventSerializer(serializers.ModelSerializer):
    category = serializers.SerializerMethodField("get_category")
    tags = serializers.SerializerMethodField("get_tags")
    users = serializers.SerializerMethodField('get_users')

    class Meta:
        model = Event
        fields = ["id", "name", "category", "date", "location", "price", "description", "tags", "users"]

    def get_category(self, event):
        return event.category.name

    def get_tags(self, event):
        tags = Tag.objects.filter(event=event)
        tags_name = []
        for tag in tags:
            tags_name.append(tag.name)
        return tags_name

    def get_users(self, event):
        users_joined = UserJoined.objects.filter(event=event)
        users = []
        for user in users_joined:
            users.append(user.user)
        return UserMinSerializer(users, many=True).data

class CreateEventSerializer(serializers.ModelSerializer):
    tags = serializers.CharField(max_length=255, required=True)

    class Meta:
        model = Event
        fields = ["id", "name", "category", "date", "location", "price", "description", "tags"]

    def get_category(self, event):
        return event.category.name

    def get_tags(self, event):
        return Tag.objects.filter(event=event).values_list('name')

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['name']

class EventsSearchSerializer(SearchBaseSerializer):
    name = serializers.CharField(required=False)
    category = serializers.CharField(required=False)
    date = serializers.DateField(required=False)
    location = serializers.CharField(required=False)
    price = serializers.FloatField(required=False)
    tags = serializers.CharField(required=False)

    class Meta:
        fields = ['name', 'category', 'date', 'location', 'price', 'tags', 'perPage', 'page']
