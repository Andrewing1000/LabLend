"""
URL mapping for the user API.
"""
from django.urls import include, path
from rest_framework.routers import SimpleRouter

from user import views

app_name = 'user'

router = SimpleRouter()
router.register('roles', views.RoleViewSet, basename='role')

urlpatterns = [
    path('list/', views.ListUsersView.as_view(), name = 'list'),
    path('manage/', views.ManageUserView.as_view(), name='manage'),
    path('create/', views.CreateUserView.as_view(), name='create'),
    path('token/', views.CreateTokenView.as_view(), name='token'),
    path('me/', views.UserProfileView.as_view(), name = 'me'),
    path('log/', views.ListUserLogsView.as_view(), name = 'log' ),
    path('events/', views.ListSecurityEventsView.as_view(), name='events'),
    path('logout/', views.LogoutView.as_view(), name = 'logout'),
    path('manage/reset-link/', views.ResetLinkView.as_view(),
         name='reset-link'),
    path('password-link/check/', views.PasswordLinkCheckView.as_view(),
         name='password-link-check'),
    path('password-link/', views.PasswordLinkUseView.as_view(),
         name='password-link'),
    path('permissions/', views.ListPermissionsView.as_view(),
         name='permissions'),
    path('', include(router.urls)),
]
