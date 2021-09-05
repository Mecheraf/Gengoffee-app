from django.db.models import CharField
from django.db.models.functions import Lower
from drf_yasg.utils import swagger_auto_schema
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.authtoken.serializers import AuthTokenSerializer
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response

from Auth.models import Account
from Auth.schemas import RegisterSchema, LoginSchema, LogoutSchema, GetUserSchema, UpdateUserSchema, UserSearchSchema, \
    UserGetSchema
from Auth.serializers import RegistrationSerializer, AccountPropertiesSerializer
from BackEnd.miscs import get_page, ErrorCode, is_admin, is_member
from BackEnd.views import ErrorView


@swagger_auto_schema(method=RegisterSchema.method, responses=RegisterSchema.response,
                     request_body=RegisterSchema.request_body)
@api_view(['POST'])
@permission_classes([AllowAny])
def api_register_user_view(request):
    serializer = RegistrationSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        token = Token.objects.get(user=user).key
        data = {
            'response': "Successfully registered new user.",
            'username': user.username,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'age': user.age,
            'city': user.city,
            'country': user.country,
            'gender': user.gender,
            'token': token,
        }

        return Response(data, status=status.HTTP_201_CREATED)
    else:
        data = serializer.errors
        return Response(data, status=status.HTTP_400_BAD_REQUEST)


@swagger_auto_schema(method=LoginSchema.method, responses=LoginSchema.response, request_body=LoginSchema.request_body)
@api_view(['POST'])
@permission_classes([AllowAny])
def api_login_user_view(request):
    serializer = AuthTokenSerializer(data=request.data, context={'request': request})
    if serializer.is_valid():
        user = serializer.validated_data['user']
        token, created = Token.objects.get_or_create(user=user)
        return Response({'user': AccountPropertiesSerializer(user).data, 'token': token.key})
    data = serializer.errors
    return Response(data, status=status.HTTP_400_BAD_REQUEST)


@swagger_auto_schema(method=LogoutSchema.method, responses=LogoutSchema.response)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def api_logout_user_view(request):
    operation = request.user.auth_token.delete()
    if operation:
        return Response(status=status.HTTP_200_OK)
    else:
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@swagger_auto_schema(method=GetUserSchema.method, responses=GetUserSchema.response)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def api_user_info_view(request):
    try:
        account = request.user
    except Account.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    serializer = AccountPropertiesSerializer(account)
    return Response(serializer.data)


@swagger_auto_schema(method=UpdateUserSchema.method, responses=UpdateUserSchema.response, request_body=UpdateUserSchema.request_body)
@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def api_user_update_view(request):
    try:
        account = request.user
    except Account.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    username = request.data.get('username', None)
    email = request.data.get('email', None)
    avatar = request.data.get('avatar', None)
    first_name = request.data.get('first_name', None)
    last_name = request.data.get('last_name', None)
    age = request.data.get('age', None)
    city = request.data.get('city', None)
    country = request.data.get('country', None)
    gender = request.data.get('gender', None)
    role = request.data.get('role', None)
    nationality = request.data.get('nationality', None)

    if username is not None:
        account.username = username

    if email is not None:
        account.email = email

    if first_name is not None:
        account.first_name = first_name

    if last_name is not None:
        account.last_name = last_name

    if city is not None:
        account.city = city

    if country is not None:
        account.country = country

    if gender is not None:
        account.gender = gender

    if age is not None:
        account.age = age

    if avatar is not None:
        account.avatar = avatar
        account.save_avatar()
    else:
        account.save()

    if is_admin(request.user) and role is not None:
        account.change_role(role)

    if nationality is not None:
        account.change_nationality(nationality)

    return Response(data=AccountPropertiesSerializer(account).data)


@swagger_auto_schema(method=UserSearchSchema.method, responses=UserSearchSchema.response, query_serializer=UserSearchSchema.query_serializer)
@api_view(['GET'])
@permission_classes([AllowAny])
def api_user_search_view(request):
    CharField.register_lookup(Lower)
    users = Account.object.all()

    if 'username' in request.data:
        users = users.filter(username__unaccent__lower__trigram_similar=request.data['username'])

    if 'role' in request.data:
        users = users.filter(role=request.data['role'])

    if 'nationality' in request.data:
        users = users.filter(nationality=request.data['nationality'])

    return get_page(request, users.order_by('username'), AccountPropertiesSerializer)


@swagger_auto_schema(method=UserGetSchema.method, responses=UserGetSchema.response)
@api_view(['GET'])
@permission_classes([AllowAny])
def api_user_get_view(request, userId):
    try:
        user = Account.object.get(id=userId)
    except Account.DoesNotExist:
        return ErrorView({
            "User": "No user found for this id"
        }, ErrorCode.BadParameterCode)

    return Response(data=AccountPropertiesSerializer(user).data)

@swagger_auto_schema(method=UserGetSchema.method, responses=UserGetSchema.response)
@api_view(['GET'])
@permission_classes([AllowAny])
def delete_user(request, userId):
    try: 
        user = Account.object.get(id = userId)
        user.delete()

    except Account.DoesNotExist:
        return ErrorView({
            "User": "No user found for this id"
        }, ErrorCode.BadParameterCode)

    return Response(data=AccountPropertiesSerializer(user).data)