from django.urls import path
from .views import hello, chat, end

urlpatterns = [
    path('hello/', hello),
    # path('start/', start),
    path('chat/', chat),
    path('end/', end)
]
