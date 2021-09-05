from rest_framework.authtoken.serializers import AuthTokenSerializer
from Auth.serializers import RegistrationSerializer, UserUpdateSerializer, UserSearchSerializer
from Auth.responses import RegistrationResponse, LoginResponse, UserResponse

from drf_yasg import openapi

from BackEnd.serializers import SearchBaseSerializer


class RegisterSchema:
    method = 'POST'

    response = {
        200: openapi.Response('User created with the token', RegistrationResponse),
        400: openapi.Response('Detail of what going wrong')
    }

    request_body = RegistrationSerializer

class LoginSchema:
    method = 'POST'

    response = {
        200: openapi.Response('User logged with the token', LoginResponse),
        400: openapi.Response('Detail of what going wrong')
    }

    request_body = AuthTokenSerializer

class LogoutSchema:
    method = 'GET'

    response = {
        200: openapi.Response('User has logout'),
        500: openapi.Response('Something went wrong')
    }

class GetUserSchema:
    method = 'GET'

    response = {
        200: openapi.Response('User logged', UserResponse),
        404: openapi.Response('Unauthorized')
    }

class UpdateUserSchema:
    method = 'PUT'

    response = {
        200: openapi.Response('User updated', UserResponse),
        404: openapi.Response('Unauthorized')
    }

    request_body = UserUpdateSerializer


class UserSearchSchema:
    method = 'GET'

    response = {
        200: openapi.Response('User founds', UserResponse)
    }

    query_serializer = SearchBaseSerializer


class UserGetSchema:
    method = 'GET'

    response = {
        200: openapi.Response('User founds', UserResponse)
    }