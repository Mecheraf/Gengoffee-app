from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView


def NotFoundView(request, exception):
    print(exception)
    return Response({
        "message": "Not found"
    }, status=status.HTTP_404_NOT_FOUND)


def ErrorView(errors, code):
    return Response({
        "message": "Bad Request",
        "code": code,
        "data": errors
    }, status=status.HTTP_400_BAD_REQUEST)


def UnauthorizedView():
    return Response({
        "message": "Unauthorized"
    }, status=status.HTTP_401_UNAUTHORIZED)


def TokenErrors(error):
    if error == 'TokenExpired':
        return Response({
            "message": "Unauthorized, token has expired"
        }, status=status.HTTP_401_UNAUTHORIZED)
    return UnauthorizedView()
