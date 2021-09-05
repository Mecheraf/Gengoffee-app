from django.urls import path

from Auth import views

urlpatterns = [
    path('', views.api_user_info_view, name='GetAccount'),
    path('users', views.api_user_search_view, name='SearchAccount'),
    path('user/<int:userId>', views.api_user_get_view, name='SearchAccount'),
    path('register', views.api_register_user_view, name='Register'),
    path('login', views.api_login_user_view, name='Login'),
    path('logout', views.api_logout_user_view, name='Logout'),
    path('update', views.api_user_update_view, name='UpdateAccount'),
    path('delete/<int:userId>', views.delete_user, name="DeleteUser"),
]
