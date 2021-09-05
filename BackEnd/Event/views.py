from django.db.models import CharField
from django.db.models.functions import Lower
from drf_yasg.utils import swagger_auto_schema
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response

from BackEnd.miscs import get_page
from Event.models import Event, Tag, UserJoined
from Event.schemas import CreateCategorySchema, CreateEventSchema, GetEventSchema, GetAllEventSchema, SearchEventSchema
from Event.serializers import EventSerializer, CategorySerializer, CreateEventSerializer


@swagger_auto_schema(method=CreateCategorySchema.method, responses=CreateCategorySchema.response, request_body=CreateCategorySchema.request_body)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_category(request):
    serializer = CategorySerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    else:
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@swagger_auto_schema(method=CreateEventSchema.method, responses=CreateEventSchema.response, request_body=CreateEventSchema.request_body)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_event(request):
    serializer = CreateEventSerializer(data=request.data)
    if serializer.is_valid():
        new_event = Event(
            name=serializer.validated_data['name'],
            category=serializer.validated_data['category'],
            date=serializer.validated_data['date'],
            location=serializer.validated_data['location'],
            price=serializer.validated_data['price'],
            description=serializer.validated_data['description']
        )
        new_event.save()
        tags = serializer.validated_data['tags'].split(',')
        for tag in tags:
            Tag(name=tag, event=new_event).save()

        return Response(EventSerializer(new_event).data, status=status.HTTP_201_CREATED)
    else:
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@swagger_auto_schema(method=GetEventSchema.method, responses=GetEventSchema.response)
@api_view(['GET'])
@permission_classes([AllowAny])
def get_event(request, eventId):
    try:
        event = Event.objects.get(id=eventId)
    except Event.DoesNotExist:
        return Response({
            "Event": "Event not found for this id"
        }, status.HTTP_404_NOT_FOUND)

    return Response(EventSerializer(event).data, status=status.HTTP_200_OK)

@swagger_auto_schema(method=GetAllEventSchema.method, responses=GetAllEventSchema.response)
@api_view(['GET'])
@permission_classes([AllowAny])
def events_all(request):
    return get_page(request, Event.objects.all(), EventSerializer)

@swagger_auto_schema(method=SearchEventSchema.method, responses=SearchEventSchema.response, query_serializer=SearchEventSchema.query_serializer)
@api_view(['GET'])
@permission_classes([AllowAny])
def events_search(request):
    CharField.register_lookup(Lower)

    if 'tags' in request.GET:
        tags = request.GET['tags'].replace(' ', '').split(',')
        events_found = []
        for tag in tags:
            if tag != '':
                events_found.append(list(Tag.objects.filter(name__icontains=tag).values_list('event__id', flat=True)))
        if len(events_found) == 0:
            events = Event.objects.none()
        elif len(events_found) == 1:
            events = Event.objects.filter(id__in=events_found[0])
        else:
            previous_events = events_found[0]
            same_event = []
            for event in events_found:
                if event == previous_events:
                    continue
                for same in list(set(previous_events).intersection(set(event))):
                    same_event.append(same)
                previous_events = event
            events = Event.objects.filter(id__in=same_event)
    else:
        events = Event.objects.all()

    if 'name' in request.GET:
        events = events.filter(name__unaccent__lower__trigram_similar=request.GET['name'])
    if 'category' in request.GET:
        events = events.filter(category=request.GET['category'])
    if 'date' in request.GET:
        events = events.filter(date=request.GET['date'])
    if 'location' in request.GET:
        events = events.filter(location__unaccent__lower__trigram_similar=request.GET['location'])
    if 'isFree' in request.GET:
        if request.GET['isFree'] == "true":
            events = events.exclude(price__gt=0)
        else:
            events = events.filter(price__gt=0)

    return get_page(request, events.order_by('name'), EventSerializer)

@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def event_join(request, eventId):
    try:
        event = Event.objects.get(id=eventId)
    except Event.DoesNotExist:
        return Response({
            "Event": "Event not found for this id"
        }, status.HTTP_404_NOT_FOUND)

    try:
        UserJoined.objects.get(user=request.user, event=event)
        return Response({
            "User": "User already joined this event"
        }, status.HTTP_401_UNAUTHORIZED)
    except UserJoined.DoesNotExist:
        UserJoined(user=request.user, event=event).save()
        return Response({
            "User": "User has joined this event"
        }, status.HTTP_200_OK)

@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def event_quit(request, eventId):
    try:
        event = Event.objects.get(id=eventId)
    except Event.DoesNotExist:
        return Response({
            "Event": "Event not found for this id"
        }, status.HTTP_404_NOT_FOUND)

    try:
        UserJoined.objects.get(user=request.user, event=event).delete()
        return Response({
            "User": "User has quited this event"
        }, status.HTTP_200_OK)
    except UserJoined.DoesNotExist:
        return Response({
            "User": "User doesn't joined this event"
        }, status.HTTP_401_UNAUTHORIZED)