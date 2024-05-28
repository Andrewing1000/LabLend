"""
URL mapping for the user API.
"""
from django.urls import path

from user import views

app_name = 'user'

urlpatterns = [
    path('list/', views.ListUsersView.as_view(), name = 'list'),
    path('create/admin/', views.CreateLabAdminView.as_view(), name = 'create/admin'),
    path('manage/', views.ManageUserView.as_view(), name='manage'),
    path('create/', views.CreateLabAssistantView.as_view(), name='create'),
    path('token/', views.CreateTokenView.as_view(), name='token'),
    path('me/', views.UserProfileView.as_view(), name = 'me'),
    path('log/', views.ListUserLogsView.as_view(), name = 'log' ),
    path('logout/', views.LogoutView.as_view(), name = 'logout'),
]