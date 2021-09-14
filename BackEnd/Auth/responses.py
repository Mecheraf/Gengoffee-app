from rest_framework import serializers


class BaseSerializer(serializers.Serializer):
    def update(self, instance, validated_data):
        pass

    def create(self, validated_data):
        pass


class PersonalInfoCharResponse(BaseSerializer):
    value = serializers.CharField(required=False)
    showValue = serializers.BooleanField(required=False)


class PersonalInfoIntResponse(BaseSerializer):
    value = serializers.IntegerField(required=False)
    showValue = serializers.BooleanField(required=False)


class PersonalInfoGenderResponse(BaseSerializer):
    value = serializers.IntegerField(required=False, min_value=0, max_value=3)
    showValue = serializers.BooleanField(required=False)


class UserResponse(BaseSerializer):
    username = serializers.CharField(required=False)
    email = serializers.EmailField(required=False)
    first_name = PersonalInfoCharResponse()
    last_name = PersonalInfoCharResponse()
    age = PersonalInfoIntResponse()
    city = PersonalInfoCharResponse()
    country = PersonalInfoCharResponse()
    gender = PersonalInfoGenderResponse()
    avatar = serializers.ImageField(required=False)
    role = serializers.CharField(required=False, max_length=3, min_length=3)
    nationality = serializers.CharField(required=False, max_length=5, min_length=5)

    class Meta:
        fields = ['username', 'email', 'first_name', 'last_name', 'age', 'city', 'country',
                  'gender', 'avatar', 'role', 'nationality']


class RegistrationResponse(BaseSerializer):
    username = serializers.CharField(required=False)
    email = serializers.EmailField(required=False)
    first_name = serializers.CharField(required=False)
    last_name = serializers.CharField(required=False)
    age = serializers.IntegerField(required=False)
    city = serializers.CharField(required=False)
    country = serializers.CharField(required=False)
    gender = serializers.IntegerField(required=False, min_value=0, max_value=3)
    avatar = serializers.ImageField(required=False)
    token = serializers.CharField(required=False)
    role = serializers.CharField(required=False, max_length=3, min_length=3)
    nationality = serializers.CharField(required=False, max_length=5, min_length=5)

    class Meta:
        fields = ['username', 'email', 'first_name', 'last_name', 'age', 'city', 'country',
                  'gender', 'avatar', 'token', 'role', 'nationality']


class LoginResponse(BaseSerializer):
    user = UserResponse()
    token = serializers.CharField(required=False)

    class Meta:
        fields = ['user', 'token']
