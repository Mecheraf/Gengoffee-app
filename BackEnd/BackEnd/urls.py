from django.conf.urls import url
from django.contrib import admin
from django.urls import path, include
from django.views.static import serve
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

from BackEnd import settings

schema_view = get_schema_view(
   openapi.Info(
      title="Gengoffee",
      default_version='v0.1',
      description="Api de Gengoffee",
      terms_of_service="https://www.google.com/policies/terms/",
   ),
   public=True,
   permission_classes=(permissions.AllowAny,),
)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('Auth.urls')),
    path('api/event/', include('Event.urls')),

    url(r'^swagger(?P<format>\.json|\.yaml)$', schema_view.without_ui(cache_timeout=0), name='schema-json'),
    url(r'^swagger/$', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    url(r'^redoc/$', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),

    url(r'^media/(?P<path>.*)$', serve, {'document_root': settings.MEDIA_ROOT, })
]
