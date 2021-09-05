from rest_framework import serializers

from Auth.models import Account


class RegistrationSerializer(serializers.ModelSerializer):
    password2 = serializers.CharField(style={'input_type': 'password'}, write_only=True)

    class Meta:
        model = Account
        fields = ['username', 'email', 'password', 'password2', 'first_name', 'last_name', 'age', 'city', 'country',
                  'gender', 'nationality']
        extra_kwargs = {
            'password': {'write_only': True},
        }

    def save(self, **kwargs):
        user = Account(
            username=self.validated_data['username'],
            email=self.validated_data['email'],
            first_name=self.validated_data['first_name'],
            last_name=self.validated_data['last_name'],
            age=self.validated_data['age'],
            city=self.validated_data['city'],
            country=self.validated_data['country'],
            gender=self.validated_data['gender'],
        )
        password = self.validated_data['password']
        password2 = self.validated_data['password2']
        if password != password2:
            raise serializers.ValidationError({'password': 'Passwords must match'})
        user.set_password(password)
        user.save()
        return user


class UserUpdateSerializer(serializers.ModelSerializer):
    def update(self, instance, validated_data):
        pass

    def create(self, validated_data):
        pass

    username = serializers.CharField(required=False)
    email = serializers.EmailField(required=False)
    first_name = serializers.CharField(required=False)
    last_name = serializers.CharField(required=False)
    age = serializers.IntegerField(required=False)
    city = serializers.CharField(required=False)
    country = serializers.CharField(required=False)
    gender = serializers.IntegerField(required=False, min_value=0, max_value=3)
    role = serializers.CharField(required=False, max_length=3)
    nationality = serializers.CharField(required=False, max_length=3)

    class Meta:
        model = Account
        fields = ['username', 'email', 'first_name', 'last_name', 'age', 'city', 'country',
                  'gender', 'avatar', 'role', 'nationality']


class AccountPropertiesSerializer(serializers.ModelSerializer):
    first_name = serializers.SerializerMethodField('get_first_name')
    last_name = serializers.SerializerMethodField('get_last_name')
    age = serializers.SerializerMethodField('get_age')
    city = serializers.SerializerMethodField('get_city')
    country = serializers.SerializerMethodField('get_country')
    gender = serializers.SerializerMethodField('get_gender')

    class Meta:
        model = Account
        fields = ['id', 'username', 'email', 'avatar', 'first_name', 'last_name', 'age', 'city', 'country', 'gender', 'avatar', 'role', 'nationality']

    def get_first_name(self, account):
        return PersonalDataSerializer(account.first_name, account.show_first_name).data

    def get_last_name(self, account):
        return PersonalDataSerializer(account.last_name, account.show_last_name).data

    def get_age(self, account):
        return PersonalDataSerializer(account.age, account.show_age).data

    def get_city(self, account):
        return PersonalDataSerializer(account.city, account.show_city).data

    def get_country(self, account):
        return PersonalDataSerializer(account.country, account.show_country).data

    def get_gender(self, account):
        return PersonalDataSerializer(account.gender, account.show_gender).data


class PersonalDataSerializer:
    def __init__(self, value, show_value):
        self.data = {
            'value': value,
            'showValue': show_value
        }

class UserSearchSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ['username', 'role', 'nationality']

class UserMinSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ['id', 'username', 'avatar']
