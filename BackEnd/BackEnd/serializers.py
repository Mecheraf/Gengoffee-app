from rest_framework import serializers

class SearchBaseSerializer(serializers.Serializer):
    def update(self, instance, validated_data):
        pass

    def create(self, validated_data):
        pass

    perPage = serializers.IntegerField(min_value=1, required=False)
    page = serializers.IntegerField(min_value=1, required=False)

    class Meta:
        fields = ['perPage', 'page']



class UsersSearchBaseSerializer(SearchBaseSerializer):
    username = serializers.CharField(required=False)

    class Meta:
        fields = ['username', 'perPage', 'page']