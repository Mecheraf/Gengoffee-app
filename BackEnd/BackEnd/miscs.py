from django.core.paginator import Paginator
from rest_framework import status
from rest_framework.response import Response

from Auth.models import Role
from BackEnd.views import ErrorView


def get_page(request, objects, serializer):
    per_page = 8
    page = 1

    if 'perPage' in request.GET:
        try:
            per_page = int(request.GET['perPage'])
        except ValueError:
            return ErrorView({
                'perPage': 'perPage must be an integer'
            }, ErrorCode.FormErrorCode)

    if 'page' in request.GET:
        try:
            page = int(request.GET['page'])
        except ValueError:
            return ErrorView({
                'page': 'page must be an integer'
            }, ErrorCode.FormErrorCode)

    paginator = Paginator(objects, per_page)
    objects_page = paginator.get_page(page)

    if page == 0 or int(page) > paginator.num_pages:
        return Response(status=status.HTTP_400_BAD_REQUEST)

    return Response({
        "message": "OK",
        "data": serializer(objects_page, many=True).data,
        "pager": {
            "current": objects_page.number,
            "total": paginator.num_pages
        }
    }, status=status.HTTP_200_OK)

class ErrorCode:
    FormErrorCode = 1001
    BadParameterCode = 1002

def is_admin(user):
    return user.role == Role.ADMIN

def is_moderator(user):
    return user.role == Role.MODERATOR

def is_member(user):
    return user.role == Role.MEMBER
