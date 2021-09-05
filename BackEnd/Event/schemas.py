from rest_framework.authtoken.serializers import AuthTokenSerializer

from Event.responses import EventResponse, CategoryResponse
from Event.serializers import EventSerializer, CategorySerializer, CreateEventSerializer, EventsSearchSerializer

from drf_yasg import openapi

from BackEnd.serializers import SearchBaseSerializer

class CreateCategorySchema:
    method = 'POST'

    response = {
        200: openapi.Response('Category created', CategoryResponse),
        400: openapi.Response('Detail of what going wrong')
    }

    request_body = CategorySerializer

class CreateEventSchema:
    method = 'POST'

    response = {
        200: openapi.Response('Category created', EventResponse),
        400: openapi.Response('Detail of what going wrong')
    }

    request_body = EventSerializer

class GetEventSchema:
    method = 'GET'

    response = {
        200: openapi.Response('Category created', EventResponse),
        404: openapi.Response('Event not found')
    }

class GetAllEventSchema:
    method = 'GET'

    response = {
        200: openapi.Response('Category created', EventResponse(many=True)),
    }

class SearchEventSchema:
    method = 'GET'

    response = {
        200: openapi.Response('Events founds', EventResponse(many=True))
    }

    query_serializer = EventsSearchSerializer