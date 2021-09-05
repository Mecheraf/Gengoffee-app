from rest_framework import serializers

from Event.models import Tag


class BaseSerializer(serializers.Serializer):
    def update(self, instance, validated_data):
        pass

    def create(self, validated_data):
        pass

class CategoryResponse(BaseSerializer):
    name = serializers.CharField(required=False)

class EventResponse(BaseSerializer):
    id = serializers.IntegerField(required=False)
    name = serializers.CharField(required=False)
    category = serializers.CharField(required=False)
    date = serializers.DateTimeField(required=False)
    location = serializers.CharField(required=False)
    price = serializers.FloatField(required=False)
    description = serializers.CharField(required=False)
    tags = serializers.ListField(required=False)
    users = serializers.ListField(required=False)
