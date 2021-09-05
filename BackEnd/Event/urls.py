from django.urls import path

from Event import views

urlpatterns = [
    path("<int:eventId>", views.get_event),
    path("create", views.create_event),
    path("category/create", views.create_category),
    path("all", views.events_all),
    path("search", views.events_search),
    path("join/<int:eventId>", views.event_join),
    path("quit/<int:eventId>", views.event_quit),
]
